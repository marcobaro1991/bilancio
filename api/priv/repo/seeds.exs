alias Bilancio.Repo, as: Repo
alias Bilancio.Application.User, as: UserApplication

alias Bilancio.Schema.{
  User,
  Movement,
  Category
}

users = [
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    first_name: "Marco",
    last_name: "Baroni",
    password: UserApplication.encode_password("diocane"),
    email: "baroni.marco.91@gmail.com",
    status: :active,
    registration_type: :default
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    first_name: "Rocco",
    last_name: "Papaleo",
    password: UserApplication.encode_password("roccopapaleopassword"),
    email: "rocco.papaleo.not.active@gmail.com",
    status: :not_active,
    registration_type: :default
  },
  %{
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    first_name: "Vincenzo",
    last_name: "Ferragamo",
    password: UserApplication.encode_password("vincenzoferragamopassword"),
    email: "vincenzo.ferragamo@gmail.com",
    status: :active,
    registration_type: :google
  }
]

movements = [
  # baroni.marco.91@gmail.com movements
  %{
    user_id: 1,
    title: "Fibra Tim",
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    description: "pagamento mensile fibra",
    value: 25.00,
    occurred_at: ~D[2022-07-14]
  },
  %{
    user_id: 1,
    title: "Tennis",
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    description: nil,
    value: 80.45,
    occurred_at: ~D[2022-07-15]
  },
  %{
    user_id: 1,
    title: "Spese Condominiali",
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    description: nil,
    value: 150.00,
    occurred_at: ~D[2022-07-01]
  },

  # rocco.papaleo.not.active@gmail.com
  %{
    user_id: 2,
    title: "pulizie",
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    description: nil,
    value: 15.60,
    occurred_at: ~D[2021-02-09]
  },

  # vincenzo.ferragamo@gmail.com movements
  %{
    user_id: 3,
    title: "Dazn",
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    description: nil,
    value: 29.90,
    occurred_at: ~D[2022-08-15]
  },
  %{
    user_id: 3,
    title: "Yoga",
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    description: nil,
    value: 15.90,
    occurred_at: ~D[2022-04-02]
  }
]

categories = [
  %{
    user_id: nil,
    title: "Stipendio",
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    color: "#ffffff"
  },
  %{
    user_id: 1,
    title: "Magicamerica",
    identifier: UUID.string_to_binary!(UUID.uuid4())
  },
  %{
    user_id: nil,
    title: "Mutuo",
    identifier: UUID.string_to_binary!(UUID.uuid4()),
    color: nil
  },
  %{
    user_id: 1,
    title: "Tim Mobile",
    identifier: UUID.string_to_binary!(UUID.uuid4())
  }
]

Repo.insert_all(User, users)
Repo.insert_all(Movement, movements)
Repo.insert_all(Category, categories)
