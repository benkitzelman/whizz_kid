require 'yaml'
require 'uuid'

module WhizzKid
  class Question
    attr_accessor :id, :number, :question, :answer, :closed

    def self.list_for_topics(topics, limit = 20)
      # grab all 
      all_questions = topics.reduce([]) do |question_list, topic|
        questions_file = File.join WhizzKid.root, 'questions', "#{topic}.yml"

        if File.exists?(questions_file)
          subject_questions = YAML::load(File.open(questions_file)) || []
          question_list + subject_questions.map {|attrs| new(attrs) }
        else
          question_list
        end
      end

      return [] unless all_questions

      # shuffle and grab the requested number of questions
      all_questions.shuffle!(random: Random.new(Time.now.to_i))
      last = [(all_questions.length - 1), (limit - 1)].min

      # add the sequence number
      the_set = all_questions[0..last]
      for i in 0..(the_set.length - 1)
        the_set[i].number = i + 1
      end
      the_set
    end

    def initialize(attrs = nil)
      @closed = false
      @id = UUID.new.generate(:compact).to_s
      attrs.each { |k,v| send("#{k}=", v) if respond_to?("#{k}=")} unless attrs.nil?
    end

  end
end