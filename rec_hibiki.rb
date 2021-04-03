require "mechanize"
require "json"
require "time"
require "shellwords"
require "aws-sdk-s3"

class HiBiKiRecorder
  HIBIKI_HOME = "http://hibiki-radio.jp/".freeze
  HEADERS = { "X-Requested-With" => "XMLHttpRequest", "Origin" => HIBIKI_HOME }.freeze

  ACCESS_KEY_ID = ENV["ACCESS_KEY_ID"]
  SECRET_ACCESS_KEY = ENV["SECRET_ACCESS_KEY"]
  REGION = ENV["REGION"]
  BUCKET_NAME = ENV["BUCKET_NAME"]

  def initialize
    @a = Mechanize.new
    @a.user_agent_alias = "Windows Chrome"
  end

  def call_api(url)
    page = @a.get(url, nil, HIBIKI_HOME, HEADERS)
    JSON.parse(page.body)
  end

  def get_program_info(access_id)
    call_api("https://vcms-api.hibiki-radio.jp/api/v1/programs/#{access_id}")
  end

  def get_playlist_url(video_id)
    res = call_api("https://vcms-api.hibiki-radio.jp/api/v1/videos/play_check?video_id=#{video_id}")
    res["playlist_url"]
  end

  def get_output_filename(program_info)
    updated_date = Time.parse(program_info["episode_updated_at"]).strftime("%Y%m%d")
    program_name = program_info["name"].strip
    episode_name = program_info["latest_episode_name"]
    "#{updated_date}_#{program_name}_#{episode_name}.ts"
  end

  def run_ffmpeg(playlist_url, output_filename)
    `ffmpeg -y -i #{Shellwords.escape(playlist_url)} -c copy #{Shellwords.escape(output_filename)}`
  end

  def upload_to_s3(access_id, output_filename)
    s3_resource = Aws::S3::Resource.new(
      access_key_id: ACCESS_KEY_ID,
      secret_access_key: SECRET_ACCESS_KEY,
      region: REGION,
    )
    object_key = "#{access_id}/#{output_filename}"
    object = s3_resource.bucket(BUCKET_NAME).object(object_key)
    object.upload_file(output_filename)
  end

  def have_s3_envs?
    ENV["ACCESS_KEY_ID"] \
      && ENV["SECRET_ACCESS_KEY"] \
      && ENV["REGION"] \
      && ENV["BUCKET_NAME"]
  end

  def save_latest_episode(access_id)
    program_info = get_program_info(access_id)
    video_id = program_info["episode"]["video"]["id"]
    playlist_url = get_playlist_url(video_id)
    output_filename = get_output_filename(program_info)

    Dir.chdir("/output") do
      run_ffmpeg(playlist_url, output_filename)
      upload_to_s3(access_id, output_filename) if have_s3_envs?
    end
  end
end

if $PROGRAM_NAME == __FILE__
  recorder = HiBiKiRecorder.new
  access_id = ARGV[0]
  recorder.save_latest_episode(access_id)
end
