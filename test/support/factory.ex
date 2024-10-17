defmodule BillionOak.Factory do
  alias BillionOak.External.{Company, CompanyAccount, CompanyRecord}
  alias BillionOak.Identity.Organization
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
end
