describe AccountsViewController do
  extend WebStub::SpecHelpers
  extend MotionResource::SpecHelpers
  
  before do
    Account.current = Account.instantiate(:id => 10)
    
    stub_request(:get, "http://mon.tinymon.org/en/accounts.json").to_return(json: { :accounts => [{ :id => 10, :status => 'success', :name => 'Test' }, { :id => 15, :status => 'failure', :name => 'Foo' }] })
    
    self.controller = AccountsViewController.alloc.init
  end
  
  tests AccountsViewController
  
  it "should show all accounts" do
    wait 0.2 do
      controller.accounts.size.should == 2
      controller.tableView.numberOfRowsInSection(0).should == 2
    end
  end
  
  it "should show account names" do
    view("Test").should.not.be.nil
    view("Foo").should.not.be.nil
  end
  
  it "should show status icons" do
    view("success.png").should.not.be.nil
    view("failure.png").should.not.be.nil
  end
  
  it "should have a check mark for the current account" do
    view("Test").superview.superview.accessoryType.should == UITableViewCellAccessoryCheckmark
  end
  
  it "should not have a check mark for other accounts" do
    view("Foo").superview.superview.accessoryType.should == UITableViewCellAccessoryNone
  end
  
  it "should refresh on pull down" do
    wait 0.5 do
      reset_stubs
      stub_request(:get, "http://mon.tinymon.org/en/accounts.json").to_return(json: { :accounts => [{ :id => 10, :status => 'success', :name => 'Test' }] })
      drag controller.tableView, :to => :bottom, :duration => 1
      
      controller.accounts.size.should == 1
      controller.tableView.numberOfRowsInSection(0).should == 1
    end
  end
  
  it "should switch account on tap" do
    stub_request(:post, "http://mon.tinymon.org/en/accounts/10/switch.json").to_return(json: {})
    
    controller.viewDeckController.mock!(:leftController, :return => UITableViewController.alloc.init)
    controller.viewDeckController.mock!(:centerController=)
    
    tap "Test"
    
    1.should == 1
  end
end
