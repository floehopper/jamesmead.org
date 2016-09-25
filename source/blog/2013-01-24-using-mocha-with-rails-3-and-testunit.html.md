--- 
permalink: using-mocha-with-rails-3-and-testunit.txt
created_at: 2013-01-24 11:32:00 +00:00
updated_at: 2013-01-24 11:32:00 +00:00
title: Using Mocha with Rails 3 and Test::Unit
description: Explains more of the compatibility issues.
categories:
keywords: mocha mock object testing ruby rails testunit compatibility
guid: 530fbbdd-7f26-4a97-b318-b3d128c6ca0a
---

As I mentioned in my [previous post](/blog/2013-01-24-using-mocha-with-rails-3-and-minitest), there's been some recent confusion over which versions of [Mocha](https://github.com/freerange/mocha) are compatible with which versions of [Rails](http://rubyonrails.org/). In this post, I explain how to use Mocha with Rails and Test::Unit.

Unfortunately due to Rails relying on Mocha & [Test::Unit](https://github.com/test-unit/test-unit) internals, there is a problem with using recent released versions of Rails with the latest version of Mocha and recent versions of the Test::Unit [gem](http://rubygems.org/gems/test-unit). You may see errors like these:

#### Rails 3.0.x

<pre>
  <code>
    .../gems/ruby/1.9.1/gems/activesupport-3.0.19/lib/active_support/dependencies.rb:483:in `load_missing_constant':
      Mocha::Integration is not missing constant AssertionCounter! (ArgumentError)
  </code>
</pre>

#### Rails 3.1.x

<pre>
  <code>
    .../gems/ruby/1.9.1/gems/activesupport-3.1.10/lib/active_support/testing/setup_and_teardown.rb:108:in `retrieve_mocha_counter':
      uninitialized constant Mocha::Integration::TestUnit::AssertionCounter (NameError)
  </code>
</pre>

#### Rails 3.2.x

<pre>
  <code>
    .../gems/ruby/1.9.1/gems/activesupport-3.2.11/lib/active_support/testing/setup_and_teardown.rb:110:in `retrieve_mocha_counter':
      uninitialized constant Mocha::MonkeyPatching (NameError)
  </code>
</pre>

There are a couple of ways to fix these errors:

### Option 1 - Use "edge" Rails or one of the relevant "stable" branches of Rails

<pre>
  <code class="prettyprint">
    # Gemfile
    gem "rails", git: "git://github.com/rails/rails.git", branch: "3-2-stable"
    group :test do
      gem "mocha", :require => false
    end

    # test/test_helper.rb
    require "mocha/setup"
  </code>
</pre>

Although obviously it isn't ideal using an _unreleased_ version of Rails. You could always lock things down further by using the Bundler `:ref` option to restrict the version of Rails to a specific `SHA`.

### Option 2 - Downgrade to Mocha 0.12.8

<pre>
  <code class="prettyprint">
    # Gemfile in Rails app
    gem "mocha", "~> 0.12.8", :require => false

    # At bottom of test_helper.rb
    require "mocha"
  </code>
</pre>

Note: This isn't as bad as it sounds, because there aren't many changes in Mocha 0.13.x that are not in 0.12.x. Please [let us know](https://github.com/freerange/mocha/issues) if there are any fixes in 0.13.x that you need in 0.12.x and I will back-port them.
