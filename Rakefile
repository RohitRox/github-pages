require "rubygems"
require "bundler/setup"

posts_dir = "_posts"

desc "Begin a new post"
task :make_post, [:title] do |t, args|

  abort "Post title not specified" if args[:title].nil? || args[:title].empty?

  title = args[:title].capitalize
  slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

  filename = "#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{slug}.md"

  abort "Post already exists" if File.exist?(filename)

  puts "Creating new post: #{filename}"

  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: #{title}"
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "comments: true"
    post.puts "categories: []"
    post.puts "---"
  end
end
