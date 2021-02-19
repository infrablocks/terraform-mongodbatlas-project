require 'spec_helper'

describe 'Access' do
  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:organization_id) { vars.organization_id }
  let(:project_id) {
    output_for(:harness, "project_id", parse: true)
  }

  let(:ip_access_list) { vars.ip_access_list }

  it 'adds entries to the project IP access list for each allowed CIDR' do
    expected_cidr_block_entries = ip_access_list.select do |entry|
      entry["type"] == "cidr-block"
    end

    project_ip_access_list = mongo_db_atlas_client
        .get_project_ip_access_list(project_id)["results"]
    project_cidr_block_entries = project_ip_access_list.select do |entry|
      entry["cidrBlock"] != nil
    end

    expected_cidr_block_entries.each do |expected_cidr_block_entry|
      project_cidr_block_entry = project_cidr_block_entries.find do |entry|
        entry["cidrBlock"] == expected_cidr_block_entry["value"]
      end

      expect(project_cidr_block_entry).not_to(be_nil)
      expect(project_cidr_block_entry["comment"])
          .to(eq(expected_cidr_block_entry["comment"]))
    end
  end

  it 'adds entries to the project IP access list for each allowed IP' do
    expected_ip_address_entries = ip_access_list.select do |entry|
      entry["type"] == "ip-address"
    end

    project_ip_access_list = mongo_db_atlas_client
        .get_project_ip_access_list(project_id)["results"]
    project_ip_address_entries = project_ip_access_list.select do |entry|
      entry["ipAddress"] != nil
    end

    expected_ip_address_entries.each do |expected_ip_address_entry|
      project_ip_address_entry = project_ip_address_entries.find do |entry|
        entry["ipAddress"] == expected_ip_address_entry["value"]
      end

      expect(project_ip_address_entry).not_to(be_nil)
      expect(project_ip_address_entry["comment"])
          .to(eq(expected_ip_address_entry["comment"]))
    end
  end
end
