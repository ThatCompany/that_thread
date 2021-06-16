require_dependency 'redmine/pagination'

module Patches
    module ThatThreadPaginationHelperPatch

        def self.included(base)
            base.send(:include, InstanceMethods)
            base.class_eval do
                unloadable

                alias_method :pagination_links_full_with_paginator, :pagination_links_full
                alias_method :pagination_links_full, :pagination_links_full_without_paginator
            end
        end

        module InstanceMethods

            def pagination_links_full_without_paginator(*args)
                # Otherwise an error is raised
                pagination_links_full_with_paginator(*args) if args.first
            end

        end

    end
end
