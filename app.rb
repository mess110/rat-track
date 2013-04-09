require 'sinatra'
require 'sinatra/reloader'
require 'fileutils'
require 'json'

def extract_frames input_file, frame_rate, path
  cmd = "ffmpeg -i #{path}/#{input_file} -r #{frame_rate} #{path}/frame%06d.png"
  system cmd
end

helpers do
  def movie_frames
    Dir["public/videos/#{params[:id]}/*.png"].delete_if{|f| f.include? 'output_'}
  end

  def analyzed_frames
    Dir["public/videos/#{params[:id]}/output_*.png"]
  end
end

def video_path
  dir_count = sprintf '%06d', Dir['public/videos/*'].count
  dir_path = File.join(Dir.pwd, "public/videos/#{dir_count}")
  FileUtils.mkdir_p dir_path
  File.join(dir_path, dir_count + '.avi')
end

get '/' do
  haml :index
end

get '/analyze/:id' do
  haml :analyze
end

post '/analyze/:id' do
  system "ruby island.rb /home/cristian/rat-track/current/public/videos/#{params[:id]}"
  redirect "/analyze/#{params[:id]}"
end

post '/upload' do
  File.open(video_path, 'wb') do |f|
    f.write(params['video'][:tempfile].read)
  end

  redirect '/'
end

get '/coordinates/:id' do
  `cat public/videos/#{params[:id]}/coordinates.txt`
end

post '/coordinates/:id' do
  params.delete('splat');
  params.delete('captures');

  system "echo '#{params.to_json}' > public/videos/#{params[:id]}/coordinates.txt"
  redirect "/analyze/#{params[:id]}"
end

get '/frames/:id' do
  extract_frames "#{params[:id]}.avi", 5, "public/videos/#{params[:id]}"
  redirect "/analyze/#{params[:id]}"
end
