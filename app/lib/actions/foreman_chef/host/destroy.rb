module Actions
  module ForemanChef
    module Host
      class Destroy < Actions::EntryAction

        def plan(host)
          if (Setting::ForemanChef.auto_deletion && proxy = ::SmartProxy.find_by_id(host.chef_proxy_id))
            node_exists_in_chef = proxy.show_node(host.name)
            if node_exists_in_chef
              action_subject(host)
              plan_self :chef_proxy_id => host.chef_proxy_id
            end

            plan_action Actions::ForemanChef::Client::Destroy, host.name, proxy
          end
        end

        def run
          proxy = ::SmartProxy.find_by_id(input[:chef_proxy_id])
          action_logger.debug "Deleting #{input[:host][:name]} on proxy #{proxy.name} at #{proxy.url}"
          self.output = proxy.delete_node(input[:host][:name])
        end

        def humanized_name
          _("Delete host")
        end

        def humanized_input
          input[:host] && input[:host][:name]
        end

        def cli_example
          return unless input[:host]
          <<-EXAMPLE
hammer host delete --id '#{task_input[:host][:id]}'
          EXAMPLE
        end

      end
    end
  end
end

