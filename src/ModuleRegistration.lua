Events = {
    Update = EventDelegate(),
    Flush = EventDelegate()
}

Events.Flush.Add(mouse.apply)
Events.Flush.Add(ship.apply)
Events.Update.Add(TaskManager.Update)
Events.Update.Add(SHUD.Update)