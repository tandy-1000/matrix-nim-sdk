import
  ../../core,
  ../endpoints,
  ../../asyncutils,
  ../sharedtypes,
  types
include ../../jsonyutils


type
  RoomEventReq* = object
    eventId*: string
    roomId*: string
  RoomEventRes* = object
    content*: string
    `type`*: string
  SendRoomEventReq* = object
    eventType*: string
    roomId*: string
    stateKey*: string
    event*: RoomEvent
  SendRoomEventRes* = object
    eventId*: string
  SendMessageReq* = object
    body*: string
    msgtype*: MessageType
  SendMessageRes* = object
    eventId*: string
  RoomStateReq* = object
    roomId*: string
  RoomStateRes* = object
    roomId*: string # not in Spec
    events*: seq[StateEvent]

proc newRoomEventReq(
    client: MatrixClient,
    eventId, roomId: string
  ): PureRequest =
  let target = roomEventGet.build(client.server, pathParams = [("eventId", eventId), ("roomId", roomId)])
  return PureRequest(endpoint: target)

proc newSendRoomEventReq(
    client: MatrixClient,
    eventType, roomId, stateKey: string,
    event: RoomEvent
  ): PureRequest =
  let
    target = roomEventStateKeyPut.build(client.server, pathParams = [("eventType", eventType), ("roomId", roomId), ("stateKey", stateKey)])
    payload = event.toJson()
  return PureRequest(
    endpoint: target,
    data: payload
  )

proc newSendMessageReq(
    client: MatrixClient,
    eventType, roomId, txnId, body: string,
    msgtype: MessageType
  ): PureRequest =
  let
    target = roomEventTxnIdPut.build(client.server, pathParams = [("eventType", eventType), ("roomId", roomId), ("txnId", txnId)])
    payload = SendMessageReq(
      body: body,
      msgtype: msgtype
    )
  return PureRequest(
    endpoint: target,
    data: payload.toJson()
  )

proc newRoomStateReq(
    client: MatrixClient,
    roomId: string
  ): PureRequest =
  let target = roomStateGet.build(client.server, pathParams = ("roomId", roomId))
  return PureRequest(endpoint: target)

proc newRoomEventRes(res: PureResponse): RoomEventRes =
  return res.body.fromJson(RoomEventRes)

proc newSendRoomEventRes(res: PureResponse): SendRoomEventRes =
  return res.body.fromJson(SendRoomEventRes)

proc newSendMessageRes(res: PureResponse): SendMessageRes =
  return res.body.fromJson(SendMessageRes)

proc newRoomStateRes(roomId: string, res: PureResponse): RoomStateRes =
  return RoomStateRes(roomId: roomId, events: res.body.fromJson(seq[StateEvent]))

proc getRoomEvent*(
    client: MatrixClient,
    eventId, roomId: string
  ): Future[RoomEventRes] {.fastsync.} =
  let
    req = newRoomEventReq(
      client,
      eventId,
      roomId
    )
    res = await client.request(req)
  return newRoomEventRes(res)

proc sendRoomEvent*(
    client: MatrixClient,
    eventType, roomId: string,
    event: RoomEvent,
    stateKey: string = ""
  ): Future[SendRoomEventRes] {.fastsync.} =
  let
    req = newSendRoomEventReq(
      client,
      eventType,
      roomId,
      stateKey,
      event
    )
    res = await client.request(req)
  return newSendRoomEventRes(res)

proc sendMessage*(
    client: MatrixClient,
    eventType, roomId, txnId, body: string,
    msgtype: MessageType
  ): Future[SendMessageRes] {.fastsync.} =
  let
    req = newSendMessageReq(
      client,
      eventType,
      roomId,
      txnId,
      body,
      msgtype
    )
    res = await client.request(req)
  return newSendMessageRes(res)

proc getRoomState*(
    client: MatrixClient,
    roomId: string
  ): Future[RoomStateRes] {.fastsync.} =
  let
    req = newRoomStateReq(
      client,
      roomId
    )
    res = await client.request(req)
  return newRoomStateRes(roomId, res)
