defmodule BillionOak.Factory do
  alias BillionOak.External.{Company, CompanyAccount, CompanyRecord}
  alias BillionOak.Identity.{InvitationCode, Organization, User, Client}
  alias BillionOak.Filestore.{File, FileLocation}
  use ExMachina.Ecto, repo: BillionOak.Repo

  def company_account_factory do
    %CompanyAccount{
      id: CompanyAccount.generate_id(),
      company_id: Company.generate_id(),
      organization_id: Organization.generate_id(),
      name: Faker.Person.name(),
      rid: sequence(:rid, &"#{&1}", start_at: 100_000),
      country_code: Faker.Address.country(),
      status: :active
    }
  end

  def company_record_factory do
    %CompanyRecord{
      id: CompanyRecord.generate_id(),
      company_id: Company.generate_id(),
      organization_id: Organization.generate_id(),
      company_account_id: CompanyAccount.generate_id(),
      dedupe_id: Faker.Lorem.word(),
      content: %{
        "name" => Faker.Person.name(),
        "email" => Faker.Internet.email()
      }
    }
  end

  def company_factory do
    %Company{
      id: Company.generate_id(),
      name: Faker.Company.name(),
      handle: Faker.Lorem.word()
    }
  end

  def organization_factory do
    %Organization{
      id: Organization.generate_id(),
      company_id: Company.generate_id(),
      name: Faker.Company.name(),
      handle: Faker.Lorem.word(),
      root_company_account_rid: sequence(:root_company_account_rid, &"#{&1}", start_at: 100_000)
    }
  end

  def invitation_code_factory do
    %InvitationCode{
      id: InvitationCode.generate_id(),
      value: Faker.Lorem.word(),
      organization_id: Organization.generate_id(),
      inviter_id: User.generate_id(),
      invitee_company_account_rid: CompanyAccount.generate_id(),
      expires_at: DateTime.add(DateTime.utc_now(:second), 30, :day)
    }
  end

  def user_factory do
    %User{
      id: User.generate_id(),
      first_name: Faker.Person.first_name(),
      last_name: Faker.Person.last_name(),
      organization_id: Organization.generate_id(),
      company_account_id: CompanyAccount.generate_id(),
      wx_app_openid: Faker.Lorem.word()
    }
  end

  def client_factory do
    %Client{
      id: Client.generate_id(),
      name: Faker.Company.name(),
      secret: Faker.Lorem.word(),
      organization_id: Organization.generate_id()
    }
  end

  def file_location_factory do
    %FileLocation{
      id: FileLocation.generate_id(),
      name: Faker.Lorem.word(),
      organization_id: Organization.generate_id(),
      owner_id: User.generate_id()
    }
  end

  def file_factory do
    %File{
      id: File.generate_id(),
      name: Faker.Lorem.word(),
      content_type: Faker.Lorem.word(),
      size_bytes: Faker.random_between(100, 100_000),
      organization_id: Organization.generate_id(),
      owner_id: User.generate_id()
    }
  end
end
