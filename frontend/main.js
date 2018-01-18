import keypair from 'keypair'

main()


async function main() {
  let user
  if (!hasUser()) {
    user = await createUser()
  } else {
    user = await getUser()
  }

  let root = document.getElementById('root')
  let hello = document.createElement('h2')
  hello.innerHTML = `Hello ${user.name}`

  let pubKey = document.createElement('pre')
  pubKey.innerHTML = user.pub_key

  let nameChanger = document.createElement('input')
  nameChanger.placeholder = 'Change Name'
  nameChanger.addEventListener('keydown', async (e) => {
    if (e.keyCode === 13) {
      await updateUser({ name: e.target.value })
      window.location.reload()
    }
  })

  root.appendChild(hello)
  root.appendChild(pubKey)
  root.appendChild(nameChanger)
}


function hasUser() {
  return localStorage.userId != null
}

async function createUser() {
  let pair = keypair()

  let user = await fetch('/api/user/', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      pub_key: pair.public
    })
  }).then(res => res.json())

  localStorage.userId = user.id
  localStorage.privateKey = pair.private

  return user
}

async function getUser() {
  try {
    let user = await fetch('/api/user/' + localStorage.userId)
      .then(res => res.json())

    return user
  } catch (error) {
    localStorage.removeItem('userId')
    window.location.reload()
  }
}


async function updateUser(updates) {
  let user = await fetch('/api/user/' + localStorage.userId, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(updates)
  }).then(res => res.json())

  return user
}