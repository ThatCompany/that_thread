require_dependency 'journals_controller'

module Patches
    module ThatThreadJournalsControllerPatch

        def self.included(base)
            base.send(:include, InstanceMethods)
            base.class_eval do
                unloadable

                alias_method :update_without_level, :update
                alias_method :update, :update_with_level
            end
        end

        module InstanceMethods

            def update_with_level
                @journal.html_data = { :level => params[:level].to_i } if params[:level]
                update_without_level
            end

        end

    end
end
