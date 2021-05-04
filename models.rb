ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Music < ActiveRecord::Base
  belongs_to :message
end

class Team < ActiveRecord::Base
  has_many :messages
end

class Message < ActiveRecord::Base
  belongs_to :team
  has_many :musics
end