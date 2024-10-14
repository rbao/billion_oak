defmodule BillionOak.Factory do
  alias BillionOak.Customer.{Company, Organization, Account}
  use ExMachina.Ecto, repo: BillionOak.Repo

  def account_factory do
    %Account{
      id: Account.generate_id(),
      name: Faker.Person.name(),
      number: sequence(:number, &"#{&1}", start_at: 100_000),
      country_code: Faker.Address.country(),
      status: :active
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
      root_account_number: sequence(:root_account_number, &"#{&1}", start_at: 100_000)
    }
  end
end
