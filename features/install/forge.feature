Feature: cli/install/forge
  Puppet librarian needs to install modules from the Puppet Forge

  @veryslow
  Scenario: Installing a module and its dependencies
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  @veryveryslow
  Scenario: Installing an exact version of a module
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt', '0.0.4'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/apt/Modulefile" should match /version *'0\.0\.4'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  @veryslow
  Scenario: Installing a module with invalid versions in the forge
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apache', '0.4.0'
    mod 'puppetlabs/postgresql', '2.0.1'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apache/Modulefile" should match /name *'puppetlabs-apache'/
    And the file "modules/apache/Modulefile" should match /version *'0\.4\.0'/
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/
    And the file "modules/postgresql/Modulefile" should match /version *'2\.0\.1'/

  @slow
  Scenario: Installing a module with several constraints
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt', '>=1.0.0', '<1.0.1'
    """
    When I run `librarian-puppet install`
    Then the exit status should be 0
    And the file "modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "modules/apt/Modulefile" should match /version *'1\.0\.0'/
    And the file "modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  @slow
  Scenario: Changing the path
    Given a directory named "puppet"
    And a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/apt'
    """
    When I run `librarian-puppet install --path puppet/modules`
    And I run `librarian-puppet config`
    Then the exit status should be 0
    And the output from "librarian-puppet config" should contain "path: puppet/modules"
    And the file "puppet/modules/apt/Modulefile" should match /name *'puppetlabs-apt'/
    And the file "puppet/modules/stdlib/Modulefile" should match /name *'puppetlabs-stdlib'/

  @announce
  @veryslow
  Scenario: Handle range version numbers
    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql'
    """
    When I run `librarian-puppet install --verbose`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/

    Given a file named "Puppetfile" with:
    """
    forge "http://forge.puppetlabs.com"

    mod 'puppetlabs/postgresql', :git => 'git://github.com/puppetlabs/puppet-postgresql'
    """
    When I run `librarian-puppet install --verbose`
    Then the exit status should be 0
    And the file "modules/postgresql/Modulefile" should match /name *'puppetlabs-postgresql'/
