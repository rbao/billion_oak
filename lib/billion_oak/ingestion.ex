defmodule BillionOak.Ingestion do
  use OK.Pipe
  alias BillionOak.Ingestion.{Attempt, Mannatech}
  alias BillionOak.{Repo, Identity}

  @doc """
  Returns the list of attempts.

  ## Examples

      iex> list_attempts()
      [%Attempt{}, ...]

  """
  def list_attempts do
    Repo.all(Attempt)
  end

  def run(req) do
    req
    |> Identity.get_organization()
    ~>> Mannatech.ingest()
  end

  @doc """
  Gets a single attempt.

  Raises `Ecto.NoResultsError` if the Attempt does not exist.

  ## Examples

      iex> get_attempt!(123)
      %Attempt{}

      iex> get_attempt!(456)
      ** (Ecto.NoResultsError)

  """
  def get_attempt!(id), do: Repo.get!(Attempt, id)
end
