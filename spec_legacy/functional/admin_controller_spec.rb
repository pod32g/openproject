#-- encoding: UTF-8

#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++
require_relative '../legacy_spec_helper'
require 'admin_controller'

describe AdminController, type: :controller do
  render_views

  fixtures :all

  before do
    User.current = nil
    request.session[:user_id] = 1 # admin
  end

  it 'should index' do
    get :index
    assert_select 'div', false,
                  attributes: { class: /nodata/ }
  end

  it 'should no plugins' do
    Redmine::Plugin.clear

    get :plugins
    assert_response :success
    assert_template 'plugins'
  end

  it 'should plugins' do
    # Register a few plugins
    Redmine::Plugin.register :foo do
      name 'Foo plugin'
      author 'John Smith'
      description 'This is a test plugin'
      version '0.0.1'
      settings default: { 'sample_setting' => 'value', 'foo' => 'bar' }, partial: 'foo/settings'
    end
    Redmine::Plugin.register :bar do
    end

    get :plugins
    assert_response :success
    assert_template 'plugins'

    assert_select 'td', child: { tag: 'span', content: 'Foo plugin' }
    assert_select 'td', child: { tag: 'span', content: 'Bar' }
  end

  it 'should info' do
    get :info
    assert_response :success
    assert_template 'info'
  end

  it 'should admin menu plugin extension' do
    Redmine::MenuManager.map :admin_menu do |menu|
      menu.push :test_admin_menu_plugin_extension,
                { controller: '/admin', action: 'plugins' },
                caption: 'Test'
    end

    User.current = User.find(1)

    get :plugins
    assert_response :success
    assert_select 'a',
                  attributes: { href: '/admin/plugins' },
                  content: 'Test'

    Redmine::MenuManager.map :admin_menu do |menu|
      menu.delete :test_admin_menu_plugin_extension
    end
  end
end
