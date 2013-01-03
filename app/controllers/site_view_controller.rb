class SiteViewController < Formotion::FormController
  attr_accessor :site
  
  def initWithSite(site, parent:parent)
    @parent = parent
    @site = site
    initWithForm(build_form)
    self.title = site.name
    self
  end
  
  def initWithParent(parent)
    @parent = parent
    @site = Site.new
    initWithForm(build_edit_form)
    self.title = "New Site"
    self
  end
  
  def viewDidLoad
    if User.current.can_edit_sites?
      show_edit_button unless @site.new_record?
    end
    super
  end
  
  def edit
    self.form = build_edit_form
    self.form.controller = self
    tableView.reloadData
    self.title = site.name
    show_done_button
  end
  
  def done_editing
    @site.update_attributes(form.render)
    TinyMon.when_reachable do
      SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
      @site.save do |result, response|
        SVProgressHUD.dismiss
        if response.ok? && result
          if @site.new_record?
            @created = true
            @parent.sites << result if @parent
            self.navigationController.popViewControllerAnimated(true)
          else
            self.form = build_form
            self.form.controller = self
            tableView.reloadData
            self.title = site.name
            show_edit_button
          end
        else
          TinyMon.offline_alert
        end
      end
    end
  end
  
  def show_edit_button
    @edit_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemEdit, target:self, action:'edit')
    self.navigationItem.rightBarButtonItem = @edit_button
  end
  
  def show_done_button
    @done_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:'done_editing')
    self.navigationItem.rightBarButtonItem = @done_button
  end
  
  def delete
    @action_sheet = UIActionSheet.alloc.initWithTitle("Really delete?",
                                                             delegate:self,
                                                    cancelButtonTitle:"No",
                                               destructiveButtonTitle:"Yes, delete",
                                                    otherButtonTitles:nil)
  
    @action_sheet.showInView(UIApplication.sharedApplication.keyWindow)
  end
  
  def actionSheet(sender, clickedButtonAtIndex:index)
    if index == sender.destructiveButtonIndex
      TinyMon.when_reachable do
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskTypeClear)
        @site.destroy do |result, response|
          SVProgressHUD.dismiss
          if response.ok? && result
            @deleted = true
            @parent.sites.delete(@site) if @parent
            self.navigationController.popViewControllerAnimated(true)
          else
            TinyMon.offline_alert
          end
        end
      end
    end
  end
  
private
  def build_form
    form = Formotion::Form.new({
      sections: [{
        rows: [{
          value: site.name,
          title: "Name",
          type: :label
        }, {
          value: site.url,
          title: "Base URL",
          type: :disclose,
          key: :url
        }, {
          value: UIImage.imageNamed("#{site.status}.png"),
          title: "Status",
          type: :icon,
        }]
      }, {
        rows: [{
          title: "Health Checks",
          type: :disclose,
          key: :checks
        }]
      }]
    })
    
    form.on_select do |key|
      case key
      when :url
        UIApplication.sharedApplication.openURL(NSURL.URLWithString(site.url))
      when :checks
        navigationController.pushViewController(HealthChecksViewController.alloc.initWithSite(site), animated:true)
      end
    end
    form
  end

  def build_edit_form
    sections = [{
      rows: [{
        value: site.name,
        title: "Name",
        key: :name,
        type: :string
      }, {
        value: site.url,
        title: "Base URL",
        key: :url,
        type: :string,
        auto_correction: :no,
        auto_capitalization: :none
      }]
    }, {
      rows: [{
        title: "Save",
        type: :submit
      }]
    }, ({
      rows: [{
        title: "Delete",
        type: :delete
      }]
    } if !@site.new_record? && User.current.can_delete_sites?)].compact
    
    form = Formotion::Form.new({
      sections: sections
    })
    
    form.on_submit do
      done_editing
    end
    form.on_delete do
      delete
    end
    form
  end
end
