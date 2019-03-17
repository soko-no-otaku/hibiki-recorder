require 'mechanize'
require 'json'
require 'time'
require 'shellwords'

class HiBiKiRecorder
  HIBIKI_HOME = 'http://hibiki-radio.jp/'.freeze
  HEADERS = { 'X-Requested-With' => 'XMLHttpRequest', 'Origin' => HIBIKI_HOME }.freeze

  def initialize
    @a = Mechanize.new
    @a.user_agent_alias = 'Windows Chrome'
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
    res['playlist_url']
  end

  def output_filename(program_info)
    updated_date = Time.parse(program_info['episode_updated_at']).strftime('%Y%m%d')
    program_name = program_info['name'].strip
    episode_name = program_info['latest_episode_name']
    "output/#{updated_date}_#{program_name}_#{episode_name}.ts"
  end

  def download_latest_episode(access_id)
    program_info = get_program_info(access_id)
    video_id = program_info['episode']['video']['id']
    playlist_url = get_playlist_url(video_id)
    `ffmpeg -y -i #{Shellwords.escape(playlist_url)} -c copy #{Shellwords.escape(output_filename(program_info))}`
  end
end

HiBiKiRecorder.new.download_latest_episode(ARGV[0])
