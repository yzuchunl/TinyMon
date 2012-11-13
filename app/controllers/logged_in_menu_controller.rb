class LoggedInMenuController < UITableViewController
  ITEMS = [{
    title: "Monitoring",
    rows: [{
      title: "Sites",
      key: :sites
    }]
  }, {
    title: "Account",
    rows: [{
      title: "Switch account",
      key: :accounts
    }, {
      title: "Users",
      key: :users
    }]
  }, {
    title: "General",
    rows: [{
      title: "Log out",
      key: :logout
    }]
  }]
  
  def numberOfSectionsInTableView(tableView)
    ITEMS.size
  end

  def tableView(tableView, numberOfRowsInSection:section)
    ITEMS[section][:rows].size
  end

  def tableView(tableView, titleForHeaderInSection:section)
    ITEMS[section][:title]
  end
  
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier('Cell')
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:'Cell')
    
    cell.textLabel.text = ITEMS[indexPath.section][:rows][indexPath.row][:title]
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell
  end
  
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    viewController = case ITEMS[indexPath.section][:rows][indexPath.row][:key]
    when :sites
      SitesViewController.alloc.init
    when :accounts
      AccountsViewController.alloc.init
    when :users
      UserAccountsViewController.alloc.init
    when :logout
      logout and return
    else
      SitesViewController.alloc.init
    end
    
    self.viewDeckController.centerController = LoggedInNavigationController.alloc.initWithRootViewController(viewController)
    
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    self.viewDeckController.toggleLeftView
  end
  
  def logout
    RemoteModule::RemoteModel.default_url_options = nil
    UIApplication.sharedApplication.delegate.window.rootViewController = MonitorNavigationController.alloc.init
  end
end