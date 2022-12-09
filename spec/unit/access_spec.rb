# frozen_string_literal: true

require 'spec_helper'

describe 'access' do
  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'does not create any project IP access list entries' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'mongodbatlas_project_ip_access_list'
                ))
    end
  end

  describe 'when no IP access list provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.ip_access_list = []
      end
    end

    it 'does not create any project IP access list entries' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'mongodbatlas_project_ip_access_list'
                ))
    end
  end

  describe 'when one CIDR based IP access list entry provided' do
    before(:context) do
      @ip_access_list_entry = {
        type: 'cidr-block',
        value: '10.0.0.0/8',
        comment: 'Private network'
      }
      @plan = plan(role: :root) do |vars|
        vars.ip_access_list = [@ip_access_list_entry]
      end
    end

    it 'creates a project IP access list entry' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'mongodbatlas_project_ip_access_list'
        )
              .once)
    end

    it 'uses the provided CIDR block' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'mongodbatlas_project_ip_access_list'
        )
              .with_attribute_value(:cidr_block, '10.0.0.0/8'))
    end

    it 'uses the provided comment' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'mongodbatlas_project_ip_access_list'
        )
              .with_attribute_value(:comment, 'Private network'))
    end
  end

  describe 'when one IP address based IP access list entry provided' do
    before(:context) do
      @ip_access_list_entry = {
        type: 'ip-address',
        value: '1.1.1.1',
        comment: 'Public IP'
      }
      @plan = plan(role: :root) do |vars|
        vars.ip_access_list = [@ip_access_list_entry]
      end
    end

    it 'creates a project IP access list entry' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'mongodbatlas_project_ip_access_list'
        )
              .once)
    end

    it 'uses the provided IP address' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'mongodbatlas_project_ip_access_list'
        )
              .with_attribute_value(:ip_address, '1.1.1.1'))
    end

    it 'uses the provided comment' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'mongodbatlas_project_ip_access_list'
        )
              .with_attribute_value(:comment, 'Public IP'))
    end
  end

  describe 'when many IP access list entries provided' do
    before(:context) do
      @cidr_entry1 = {
        type: 'cidr-block',
        value: '10.0.0.0/8',
        comment: 'Private network 1'
      }
      @cidr_entry2 = {
        type: 'cidr-block',
        value: '192.168.0.0/16',
        comment: 'Private network 2'
      }
      @ip_entry1 = {
        type: 'ip-address',
        value: '1.1.1.1',
        comment: 'Public IP 1'
      }
      @ip_entry2 = {
        type: 'ip-address',
        value: '2.2.2.2',
        comment: 'Public IP 2'
      }

      @plan = plan(role: :root) do |vars|
        vars.ip_access_list = [
          @cidr_entry1, @cidr_entry2,
          @ip_entry1, @ip_entry2
        ]
      end
    end

    it 'creates a project IP access list entry for each provided' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'mongodbatlas_project_ip_access_list'
        )
              .exactly(4).times)
    end

    it 'uses the provided IP address for each IP based entry' do
      [@ip_entry1, @ip_entry2].each do |entry|
        expect(@plan)
          .to(include_resource_creation(
            type: 'mongodbatlas_project_ip_access_list'
          )
                .with_attribute_value(:ip_address, entry[:value]))
      end
    end

    it 'uses the provided CIDR for each CIDR based entry' do
      [@cidr_entry1, @cidr_entry2].each do |entry|
        expect(@plan)
          .to(include_resource_creation(
            type: 'mongodbatlas_project_ip_access_list'
          )
                .with_attribute_value(:cidr_block, entry[:value]))
      end
    end

    it 'uses the provided comment for each entry' do
      [
        @cidr_entry1, @cidr_entry2,
        @ip_entry1, @ip_entry2
      ].each do |entry|
        expect(@plan)
          .to(include_resource_creation(
            type: 'mongodbatlas_project_ip_access_list'
          )
                .with_attribute_value(:comment, entry[:comment]))
      end
    end
  end
end
