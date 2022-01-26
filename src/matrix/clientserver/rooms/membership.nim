import pkg/jsony
import ../../core
import ../endpoints
import ../../asyncutils

type
  JoinedRoomsRes* = object
    joinedRooms*: seq[string]
  JoinRoomReq* = object
    roomId*: string
  JoinRoomRes* = object
    roomId*: string

proc newJoinedRoomsRes(res: PureResponse): JoinedRoomsRes =
  return res.body.fromJson(JoinedRoomsRes)

proc newJoinRoomReq(
  client: MatrixClient,
  roomId: string,
  ): PureRequest =
  let target = roomJoinId.build(client.server, urlParams = [("roomId", roomId)])
  return PureRequest(
    endpoint: target,
    data: ""
  )

proc newJoinRoomRes(res: PureResponse): JoinRoomRes =
  return res.body.fromJson(JoinRoomRes)

proc joinedRooms*(
  client: MatrixClient,
): Future[JoinedRoomsRes] {.fastsync.} =
  let
    target = joinedRoomsGet.build(client.server)
    req = PureRequest(
      endpoint: target,
      data: ""
    )
    res = await client.request(req)
  return newJoinedRoomsRes(res)

proc joinRoom*(
  client: MatrixClient,
  roomId: string,
): Future[JoinRoomRes] {.fastsync.} =
  let
    req = newJoinRoomReq(
      client,
      roomId
    )
    res = await client.request(req)
  return newJoinRoomRes(res)