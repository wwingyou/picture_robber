# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'selenium-webdriver'
require 'base64'

if ARGV[0].nil? 
  puts "Usage: robber <keyword>"
  exit 1
end

keyword = ARGV[0]

driver = Selenium::WebDriver.for :chrome

driver.get("https://www.google.com/search?q=#{keyword}&tbm=isch")

puts driver.title

driver.manage.timeouts.implicit_wait = 500

base_dir_name = 'images'
# 디렉토리 형식 : "날짜--시간--키워드"
dir_name = "#{base_dir_name}/#{Time.now.strftime('%Y-%m-%d--%H:%M:%S')}--#{keyword}"

# Data URI scheme으로 포함된 이미지 데이터를 저장한다.
src_match = %r{^data:image/(png|jpeg|jpg);base64,([A-Za-z0-9+/=]+)$}

# 이미지 요소 리스트 가져오기
images = driver.find_elements(tag_name: 'img', class: 'rg_i')

puts "Found #{images.size} images"

Dir.mkdir(base_dir_name) unless Dir.exist?(base_dir_name)
Dir.mkdir(dir_name)

index = 0
images.each do |image|
  index += 1
  match_data = src_match.match(image.attribute('src'))
  next unless match_data

  file_content = Base64.decode64(match_data[2])

  # 바이너리 데이터를 쓰기 위해 'b' 옵션을 줌
  File.open("#{dir_name}/image_#{index}.#{match_data[1]}", 'wb') do |file|
    file.write(file_content)
  end
end

driver.quit
