class AllHealthChecksViewController < HealthChecksViewController
  include RootController
  
  def viewDidLoad
    super
    
    self.navigationItem.rightBarButtonItem = nil
    
    on_refresh do
      load_data
    end
  end
  
  def load_data
    TinyMon.when_reachable do
      HealthCheck.all do |results|
        if results
          self.all_health_checks = results
          self.change_filter(@filter)
          tableView.reloadData
        else
          TinyMon.offline_alert
        end
        end_refreshing
      end
    end
  end
end
