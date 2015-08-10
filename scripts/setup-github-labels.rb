require 'octokit'

token_file = File.expand_path("../../.github_access_token", File.dirname(__FILE__))
token = File.file?(token_file) ? File.read(token_file).strip : ''
repo_slug = ARGV.first
dry_run = ARGV.include?('--dry-run')

unless repo_slug
  puts "[!] A repo slug is required"
end

puts "Updating labels of `#{repo_slug}` repo"

LABELS = {
  # Type
  "t1:enhancement" => "02AFE1",
  "t2:defect" => "6902E1",
  "t3:discussion" => "E10288",
  "t4:internal" => "0D00D9",

  # Status
  "s1:awaiting input" => "EDCE24",
  "s2:confirmed" => "E2A72C",
  "s3:detailed" => "E28C2C",
  "s4:awaiting validation" => "F97D27",
  "s5:blocked" => "684324",
  "s6:PR exists" => "FAD8C7",

  # Difficulty
  "d1:easy" => "00B952",
  "d2:moderate" => "40741F",
  "d3:hard" => "375921",

  # Priority
  "★" => "C7C1C1",
}

MAPPINGS = {
  "feature" => "t1:enhancement",
  "bug" => "t2:defect",
  "awaiting response" => "s1:awaiting input",
  "question" => "t3:discussion",
  "easy first step" => "d1:easy",
}

#-- Helpers ------------------------------------------------------------------#

def cannonical_name(exiting_name)
  exiting_name = exiting_name.downcase
  name = LABELS.keys.find { |name| exiting_name.include?(name.split(':').last) }
  name || MAPPINGS[exiting_name]
end


#-- Run ----------------------------------------------------------------------#

client = Octokit::Client.new(:access_token => token)
user = client.user
user.login
labels = client.labels(repo_slug)
missing = LABELS.keys.dup

labels.each do |label|
  puts "\nProcessing `#{label.name}` (color #{label.color})"
  if name = cannonical_name(label.name)
    missing.delete(name)
    color = LABELS[name]
    if label.name == name && label.color == color
      puts "- 👍 `#{label.name}`"
    else
      options = {}
      if label.name != name
        puts " - updating name from `#{label.name}` `#{name}`"
        options[:name] = name
      end

      if label.color != color
        puts " - updating color from `#{label.color}` `#{color}`"
        options[:color] = color
      end

      client.update_label(repo_slug, label.name, options) unless dry_run
    end
  else
    puts "- deleting `#{label.name}`"
    client.delete_label!(repo_slug, label.name, {}) unless dry_run
  end
end

missing.each do |name|
  color = LABELS[name]
  puts "\n\Adding `#{name}` (color #{color})"
  client.add_label(repo_slug, name, color) unless dry_run
end
