namespace :db do

  task :count => :environment do
    puts "Found #{ Post.where( "created_at < ?", 1.month.ago ).count } old records"
  end

end