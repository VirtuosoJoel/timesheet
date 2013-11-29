namespace :db do
  task :delete => :environment do
    old_records = Post.where( 'created_at < ?', 1.month.ago )
    puts "Found #{ old_records.length } old records."
    if old_records.length > 0
      old_records.destroy
      puts 'Deleted old Records.'
    else
      puts 'Nothing to delete.'
    end
  end
end