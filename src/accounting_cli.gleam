import gleam/io
import gleam/list

import gsv
import simplifile

// DKB -> debit
// CC -> Credit
// TR -> debit

// Example #1
// $ gleam run -- create-account debit-normal "Current"
// $ gleam run -- create-account debit-normal "Saving"
// $ gleam run -- create-account credit-normal "VISA CC"

// Transactions
// create-transaction --credit=customer1,1000€ --debit=Winnings,810€ --debit=Tax,190€ --date 2024-10-30 --description "Invoice 4711"

// $ gleam run -- report
// Account #1 (debit)       1.000,00€
// Account #2 (credit)       (810,00€)
// Account #3 (credit)       (190,00€)

const accounts_file = "./accounts.csv"

const transactions_file = "./transactions.csv"

pub fn main() {
  let assert Ok(db) =
    database_load()
    |> create_debit_account("foo")
    |> create_transaction("Current2", "Savings", 100)

  print_report(db)
}

pub type Account {
  DebitNormal(name: String)
  CreditNormal(name: String)
}

pub type Transaction {
  Transaction(src: Account, dst: Account, desc: String, amount: Int)
}

pub type Database {
  Database(accounts: List(Account), transactions: List(Transaction))
}

pub fn database_load() -> Database {
  let assert Ok(content) = simplifile.read(from: accounts_file)
  let assert Ok(records) = gsv.to_lists(content)
  Database(accounts: list.map(records, parse_account), transactions: list.new())
}

fn parse_account(fields: List(String)) -> Account {
  let assert [name, kind] = fields
  case kind {
    "Debit" -> DebitNormal(name)
    "Credit" -> CreditNormal(name)
    _ -> {
      let msg = "Unknown account type: " <> kind
      panic as msg
    }
  }
}

pub fn create_debit_account(db: Database, name: String) -> Database {
  Database(..db, accounts: list.append(db.accounts, [DebitNormal(name)]))
}

fn create_transaction(
  db: Database,
  src: String,
  dst: String,
  amount: Int,
) -> Result(Database, String) {
  todo
}

pub fn print_report(db: Database) {
  io.println("Report")
  io.println("======")
  list.each(db.accounts, fn(acc) { io.println(acc.name) })
  io.println("")
}
