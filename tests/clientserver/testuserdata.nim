import
  std/unittest,
  pkg/matrix,
  ../config

suite "User data":
  setup:
    let
      username = getUsername()
      password = getPassword()
      homeserver = getServer()
      client = newMatrixClient(homeserver)

    try:
      let loginRes = client.login(username, password)
      client.setToken(loginRes.accessToken)
    except MatrixError as e:
      fail()
      echo e.error

  teardown:
    client.dropToken()

  suite "Profiles":
    test "Set displayname":
      try:
        let
          whoAmIResp = client.whoAmI()
          res = client.setDisplayname(whoAmIResp.userId, "testDisplayname")
        check res
      except MatrixError as e:
        fail()
        echo e.error
