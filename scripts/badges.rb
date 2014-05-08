repo_slug = ARGV.first

unless repo_slug
  puts "[!] A repo slug is required"
end

output = <<-DOC
[![Build Status](https://img.shields.io/travis/CocoaPods/#{repo_slug}/master.svg?style=flat)](https://travis-ci.org/CocoaPods/#{repo_slug})
[![Coverage](https://img.shields.io/codeclimate/coverage/github/CocoaPods/#{repo_slug}.svg?style=flat)](https://codeclimate.com/github/CocoaPods/#{repo_slug})
[![Code Climate](https://img.shields.io/codeclimate/github/CocoaPods/#{repo_slug}.svg?style=flat)](https://codeclimate.com/github/CocoaPods/#{repo_slug})
DOC

puts output
