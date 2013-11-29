class Post < ActiveRecord::Base
  attr_accessible :name, :worktype, :hours, :starttime, :endtime, :notes, :date
 
  ENGINEERNAMES =  [ "Andrew Kiernan",
                     "Andrew Loake",
                     "Andrew Mitchell",
                     "Andrew Twiselton",
                     "Andrius Stanaitis",
                     "Andrzej Jancy",
                     "Brian Murphy",
                     "Chris Murray",
                     "Claire Loughran",
                     "Claire Shields",
                     "Danique Burton",
                     "David Hunt",
                     "David Taylor",
                     "Felix Moshi",
                     "Gary Hiscutt",
                     "Ian Foote",
                     "Jack Hodge",
                     "Jamal Mohammed",
                     "Joel Pearson",
                     "John Williams",
                     "Josh Winter",
                     "Joshua Sharpless",
                     "Julie Quarton-Hill",
                     "Kamaldeen Abdulsalam",
                     "Ken Eastaff",
                     "Kibrul Chowdhury",
                     "Maciej Starkowski",
                     "Malcolm Wilson",
                     "Marco Stephenson",
                     "Mark Timms",
                     "Michael Haley",
                     "Michael Holland",
                     "Michael Mullen",
                     "Michael Thoulass",
                     "Michal Fijalkowski",
                     "Naranjan Atwal",
                     "Narinderjeet Matharu",
                     "Pat Gurney",
                     "Paul Barr",
                     "Peter Rowlson",
                     "Przemyslaw Kochanowski",
                     "Reece Winter",
                     "Richard Thurkle",
                     "Roger Marchant",
                     "Roxana Bugeac",
                     "Roy Mace",
                     "Ryan Monteith",
                     "Simon Mason",
                     "Simon Smith",
                     "Stephen Mukaro",
                     "Steve Welsh",
                     "Steven Middleton",
                     "Tim Barr",
                     "Tom Willingham",
                     "Tony Scinaldi",
                     "Tony White",
                     "Tracey Manners",
                     "Vernon Walton"
  ]

  NAMES = ENGINEERNAMES.map { |v| v.gsub(/\s+/, '') } + [ 'All' ]

  WORKTYPES =
  { 
    "Logistics" => 
      [
        "Admin",
        "Build",
        "Brokerage",
        "Driving",
        "Field",
        "Labour",
        "Project",
        "R&D",
        "QA",
        "Teardown",
        "Technical Support",
        "Training",
        "Warehouse"
      ],
    "Other" =>
      [
        "Other",
        "Break"
      ],
    "Repair" =>
      [
        "Repair Complete",
        "WIP",
        "BER"
      ]
  }  
  
  WORKTYPEEXAMPLES = {
    "Admin"             => "Paperwork / Stock Checks",
    "BER"               => "Non-RDT Job Beyond Economical Repair",
    "Brokerage"         => "Repair / Config for Brokerage",
    "Build"             => "Software Build",
    "Driving"           => "Trunk / Deliveries",
    "Field"             => "Working as a Driver / Field Engineer",
    "Labour"            => "Moving Desks / Cabling",
    "Other"             => "Detail in Notes",
    "Project"           => "Installs at Customer Site",
    "QA"                => "DOA / Quality Investigation",
    "R&D"               => "Research & Development",
    "Repair Complete"   => "Non-RDT Job Repaired",
    "Teardown"          => "Parts Harvesting",
    "Technical Support" => "Internal / Field",
    "Training"          => "Work-related Teaching / Learning",
    "WIP"               => "Non-RDT Job Work In Progress",
    "Warehouse"         => "Working in Warehouse",
    "Break"             => "Lunch / Tea Break"
  }
 
  validates :name, :presence => true
  validates :worktype, :presence => true, :format => /\A[^-]/
  validates :hours, :presence => true, :numericality => { :greater_than => 0, :less_than => 24 }
  validates :starttime, :presence => true, :format => /\A\d{1,2}\:[0-5]\d\z/
  validates :endtime, :presence => true, :format => /\A\d{1,2}\:[0-5]\d\z/
  validates :notes, :presence => true, :length => { :minimum => 4 }, :format => /\A[^=].+/
  
  before_validation :validate_values

  def self.filter( find_date, find_name )
    
    if find_name == 'All'
      where( :created_at => find_date.beginning_of_day..find_date.end_of_day ).order(:name)
    else
      where( :created_at => find_date.beginning_of_day..find_date.end_of_day, :name => find_name )
    end
  end
  
  def self.to_csv( options = {} )
    CSV.generate( options ) do |csv|
      csv << column_names
      all.each do |post|
        csv << post.attributes.values_at(*column_names)
      end
    end
  end
  
  def self.worktype_hours_by_month( date )
    totals = Hash.new(0);Post.where( :created_at => date.beginning_of_month..date.end_of_month ).each {|p| totals[p.worktype]+=p.hours.to_f };totals
  end
  
  protected
  
  def validate_values
    allow_break
    strip_whitespace
    convert_hours
    strip_leading_zeros
  end
  
  def allow_break
    self.notes = 'Break' if notes.empty? && worktype == 'Break'
  end
  
  def strip_whitespace
    %w( hours starttime endtime ).each do |name|
      send( name + '=', send( name ).strip ) if send( name ).respond_to?( :strip )
    end
  end
  
  def convert_hours
    if hours_before_type_cast && hours_before_type_cast =~ /:/
      hrs, mins = hours_before_type_cast.scan( /(\d*):(\d*)/ ).first
      self.hours = BigDecimal( ( hrs.to_f + ( mins.to_f / 60.0 ) ), 4 )
    end
  end
  
  def strip_leading_zeros
    self.starttime, self.endtime = starttime.sub(/\A0+/,''), endtime.sub(/\A0+/,'')
  end
  
end