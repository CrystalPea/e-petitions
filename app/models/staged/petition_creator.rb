module Staged
  module PetitionCreator
    def self.manager(params, request, stage, move)
      Manager.new(params, request, stage, move, self::Stages)
    end

    def self.stages
      self::Stages.stage_names
    end

    class Manager
      def initialize(params, request, stage, move, stages)
        @params = params
        @request = request
        @previous_stage = stage
        @move = move
        @stages = stages
      end

      # This is the stage we came from - the UI elements we showed the user
      # that generated these params
      attr_reader :previous_stage
      attr_reader :move
      attr_reader :stages

      def petition
        @_petition ||= build_petition
      end

      def stage
        stage_manager.result_stage.name
      end

      def stage_object
        stage_manager.result_stage.stage_object
      end

      def create_petition
        sanitize!
        stage_manager.create
      end

      private

      def stage_manager
        @_stage_manager ||= Staged::StageManager.new(stages, previous_stage, move, petition)
      end

      def sanitize!
        if petition.creator
          petition.creator.email.strip! unless petition.creator.email.blank?
          petition.creator.ip_address = @request.remote_ip
        end
        petition.action.strip! unless petition.action.blank?
      end

      def build_petition
        ::Petition.new(@params)
      end
    end
  end
end
