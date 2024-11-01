globals
[
  grid-x-inc
  grid-y-inc
  acceleration

  phase
  num-cars-stopped
  num-buses-stopped
  num-cars-slowed
  num-buses-slowed
  current-light
  current-busstop

  intersections
  intersections-west
  intersections-south
  intersections-north
  busstops
  roads
  roaddividers
  oppositeroads

  remainingcars
  remainingbuses

]


turtles-own
[
  speed
   negativespeed
  bus-speed
  ;;up-car?
  ;;up-bus?
  up-vehicle?
  down-vehicle?
  up-bus?
  down-bus?

  wait-time
  bus-wait-time

]
breed[newcars newcar]
breed[oppositecars oppositecar]
breed[newbuses newbus]
breed[oppositebuses oppsitebus]

newcars-own
[
 newcarcolor
]
oppositecars-own
[
 oppositecarcolor
]
newbuses-own
[
  newbuscolor
]
oppositebuses-own
[
  oppositebuscolor
]

patches-own
[
  intersection?
  intersection-west?
  intersection-south?
  intersection-north?
  green-light-up?

  my-row
  my-column
  my-phase
  auto?
]

to setup
  ca
  setup-globals

  setup-patches
  make-current one-of  intersections-west
  make-busstop one-of intersections

  if (num-cars > ( count roads + count oppositeroads))
  [
    user-message (word "There are too many cars for the amount of "
                       "road.  Either increase the amount of roads "
                       "by increasing the GRID-SIZE-X or "
                       "GRID-SIZE-Y sliders, or decrease the "
                       "number of cars by lowering the NUMBER slider.\n"
                       "The setup has stopped.")
    stop
  ]
  if (num-buses > ( count roads + count oppositeroads))
  [
    user-message (word "There are too many buses for the amount of "
                       "road.  Either increase the amount of roads "
                       "by increasing the GRID-SIZE-X or "
                       "GRID-SIZE-Y sliders, or decrease the "
                       "number of buses by lowering the NUMBER slider.\n"
                       "The setup has stopped.")
    stop
  ]

    setup-cars
    setup-oppositecars

    setup-buses
    setup-oppositebuses

 ask  newcars [ set-car-speed ]
  ask oppositecars  [ set-oppositecar-speed ]
 ask newbuses[ set-bus-speed ]
 ask oppositebuses[ set-oppositebus-speed ]
  reset-ticks
end


to setup-globals
  set current-light nobody
  set phase 0
  set num-cars-stopped 0
  set num-buses-stopped 0
  set grid-x-inc world-width / grid-size-x
  set grid-y-inc world-height / grid-size-y
  set remainingcars num-cars
  set remainingbuses num-buses

  set acceleration 0.099
end

to setup-patches
  ask patches
  [
    set intersection? false
    set intersection-west? false
    set intersection-north? false
    set intersection-south? false
    set auto? false
    set green-light-up? true
    set my-row -1
    set my-column -1
    set my-phase -1
    set pcolor brown + 3
  ]


   set roads patches with
    [( (floor((pxcor + max-pxcor - floor(grid-x-inc - 1)) mod grid-x-inc) = 0) or
    (floor((pycor + max-pycor) mod grid-y-inc) = 0) )]

   set oppositeroads patches with
    [((floor((pxcor + max-pxcor - floor(grid-x-inc + 1)) mod grid-x-inc) = 0) or
    (floor((pycor + max-pycor - 2) mod grid-y-inc ) = 0) )]

    set roaddividers patches with
    [(( (floor((pxcor + max-pxcor - floor(grid-x-inc)) mod grid-x-inc) = 0) ) or
    (floor((pycor + max-pycor - 1) mod grid-y-inc) = 0) )]

    ;;set up inter-secs
  set intersections roads  with
    [(floor((pxcor + max-pxcor - floor(grid-x-inc - 1)) mod grid-x-inc) = 0) and
    (floor((pycor + max-pycor) mod grid-y-inc) = 0) ]
  set intersections-west oppositeroads  with
    [(floor((pxcor + max-pxcor - floor(grid-x-inc + 1)) mod grid-x-inc) = 0) and
    (floor((pycor + max-pycor - 2) mod grid-y-inc) = 0) ]
  set intersections-south roads  with
    [(floor((pxcor + max-pxcor - floor(grid-x-inc - 1)) mod grid-x-inc ) = 0) and
    (floor((pycor + max-pycor - 2) mod grid-y-inc ) = 0) ]
  set intersections-north oppositeroads  with
    [(floor((pxcor + max-pxcor - floor(grid-x-inc + 1)) mod grid-x-inc) = 0) and
    (floor((pycor + max-pycor ) mod grid-y-inc  ) = 0) ]
  ;;set patch colors
  ask roads
  [
    set pcolor white
  ]
  ask oppositeroads
  [

      set pcolor 9.9

  ]
  ask roaddividers
  [
      set pcolor black + 5
  ]
  setup-intersections
end

to setup-intersections
  ask intersections
  [
    set intersection? true
    set green-light-up? true
    set my-phase 0
    set auto? true
    set my-row floor((pycor + max-pycor) / grid-y-inc)
    set my-column floor((pxcor + max-pxcor) / grid-x-inc)
    set-signal-colors
    set pcolor 36

  ]
  ask intersections-west
  [
    set intersection-west? true
    set green-light-up? true
    set my-phase 0
    set auto? true
        set pcolor 36
 ]
   ask intersections-south
  [
    set intersection-south? true
    set green-light-up? true
    set my-phase 0
    set auto? true
       set pcolor 36
 ]
   ask intersections-north
  [
    set intersection-north? true
    set green-light-up? true
    set my-phase 0
    set auto? true
        set pcolor 36
 ]
end

to setup-cars
  set-default-shape turtles "car"
 set  remainingcars  random (num-cars )

  create-newcars remainingcars
  [
  set speed 0
  set wait-time 0
  put-on-empty-road
  set-car-color
  ifelse intersection?
  [
    ifelse random 2 = 0
    [ set up-vehicle? true
      ]
    [ set up-vehicle? false]
  ]
  [
    ifelse (floor((pxcor + max-pxcor - floor(grid-x-inc - 1)) mod grid-x-inc) = 0)
    [
      set up-vehicle? true
      ]
    [ set up-vehicle? false   ]


   ifelse ((floor((pycor + max-pycor) mod grid-y-inc) = 0) )
    [ set up-vehicle? false       ]
    [ set up-vehicle? true
      ]

  ]
  ifelse up-vehicle?
  [ set heading 0 ]
  [ set heading 90 ]
  record-data
  ]
end
to setup-oppositecars
    set-default-shape turtles "othercar"
    set remainingcars ( num-cars - remainingcars)
   if remainingcars = 0
   [
     set remainingcars 1
     ]
  create-oppositecars  ( remainingcars )
  [
  set speed 0
  set wait-time 0
  put-on-empty-oppositeroad
  ifelse intersection?
  [
    ifelse random 2 = 0
    [ set down-vehicle? true
      ]
    [ set down-vehicle? false ]
  ]
  [

     ifelse (floor((pxcor + max-pxcor - floor(grid-x-inc + 1)) mod grid-x-inc) = 0  )
    [ set down-vehicle? true
    ]
    [ set down-vehicle? false ]

     ifelse ((floor((pycor + max-pycor - 2) mod grid-y-inc ) = 0))
    [ set down-vehicle? false
      ]
    [ set down-vehicle? true
      ]
  ]

  ifelse down-vehicle?
  [ set heading 0]
  [ set heading 90]

  set-oppositecar-color
  record-data
  ]
end

to setup-buses
  set-default-shape turtles "bus"
  set remainingbuses random(num-buses )
  create-newbuses ( remainingbuses )
  [
  set speed 0
  set bus-wait-time 0
  set size 1.4
  put-on-empty-road
  ifelse intersection?
  [
    ifelse random 2 = 0
    [ set up-vehicle? true ]
    [ set up-vehicle? false ]
  ]
  [

    ifelse (floor((pxcor + max-pxcor - floor(grid-x-inc - 1)) mod grid-x-inc) = 0)
    [ set up-vehicle? true ]
    [ set up-vehicle? false ]

    ifelse ((floor((pycor + max-pycor) mod grid-y-inc) = 0) )
    [ set up-vehicle? false ]
    [ set up-vehicle? true ]
  ]
  ifelse up-vehicle?
  [ set heading 0]
  [
    set shape "horizontalbus"
        set speed 0
    set heading 90

  ]

  set-bus-color
  record-busdata

  ]
end
to setup-oppositebuses
    set-default-shape turtles "other-bus"
    set remainingbuses (num-buses - remainingbuses)
    if remainingbuses = 0
    [
      set remainingbuses 1
      ]

  create-oppositebuses round ( remainingbuses)
  [
  set speed 0
  set bus-wait-time 0
  set size 1.4
  ;;set up-bus? true
  put-on-empty-oppositeroad
  ifelse intersection?
  [
    ifelse random 2 = 0
    [ set down-vehicle? true ]
    [ set down-vehicle? false ]
  ]
  [
     ifelse (floor((pxcor + max-pxcor - floor(grid-x-inc + 1)) mod grid-x-inc) = 0  )
    [ set down-vehicle? true ]
    [ set down-vehicle? false ]

     ifelse ((floor((pycor + max-pycor - 2) mod grid-y-inc ) = 0))
    [ set down-vehicle? false ]
    [ set down-vehicle? true ]
  ]

  ifelse down-vehicle?
  [ set heading 0 ]
  [
    set shape "horizontalbus1"
    set speed 0
    set heading 90
    ]

  set-oppositebus-color
  record-busdata

  ]
end

to put-on-empty-road
  move-to one-of roads with [not any? turtles-on self and pcolor = white]
end


to put-on-empty-oppositeroad
  move-to one-of oppositeroads with [not any? turtles-on self and pcolor = 9.9]
end



to go

  update-current
  set-signals

  set num-cars-stopped 0
  set num-buses-stopped 0
  ask newcars
  [
       set-car-speed
          fd speed
    record-data
    set-car-color
  ]
   ask oppositecars
  [
           set-oppositecar-speed
          fd  (- speed)

    record-data
    set-oppositecar-color
  ]
  ask newbuses
  [
         set-bus-speed
          fd speed
         record-busdata
    set-bus-color
  ]
  ask oppositebuses
  [
          set-oppositebus-speed
          fd (- speed)
         record-busdata
    set-oppositebus-color
  ]
  next-phase
  tick
end

;; end of go

to choose-current
  if mouse-down?
  [
    let x-mouse mouse-xcor
    let y-mouse mouse-ycor
    if [intersection?] of patch x-mouse y-mouse
    [
      update-current
      unlabel-current
      make-current patch x-mouse y-mouse
      label-current
      stop
    ]
  ]
end

to setup-busstops
  set-busstops
end

to remove-busstops
  ask intersections with [phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [
    ask patch-at -3 0 [ set pcolor 9.9 ]

  ]
  ask intersections-west with [phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [
    ask patch-at 3 0 [ set pcolor 9.9 ]

  ]
  ask intersections-south with [phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [

    ask patch-at 0 -5 [ set pcolor 9.9 ]
  ]
  ask intersections-north with [phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [

    ask patch-at 0 5 [ set pcolor 9.9 ]
  ]
end

to choose-busstop
  if mouse-down?
  [
    let x-mouse round mouse-xcor
    let y-mouse round mouse-ycor

      unlabel-busstop
      make-busstop patch x-mouse y-mouse
      label-busstop
      stop

  ]
end

to remove-busstop
   if mouse-down?
  [
    let x-mouse round mouse-xcor
    let y-mouse round mouse-ycor
      unlabel-busstop
      stop
  ]
end


to make-current [light]
  set current-light light
  set current-phase [my-phase] of current-light
  set current-auto? [auto?] of current-light
end


to make-busstop[light]
  set current-busstop light

end


to update-current
  ask current-light [
    set my-phase current-phase
    set auto? current-auto?
  ]
end

to update-busstops
  ask current-busstop[
    set my-phase current-phase
  ]
end

to label-current
  ask current-light
  [
    ask patch-at -1 1
    [
      set plabel-color black
      set plabel "current"
    ]
  ]
end


to label-busstop

  ifelse [pcolor] of patch round mouse-xcor round mouse-ycor = 38
  [
  if [ pcolor ] of patch (round (mouse-xcor) + 1) round mouse-ycor = white
  [
  ask current-busstop
  [
    ask patch-at 0 0
    [

      set pcolor 24
    ]

    ask patch-at 1 0
    [
      set plabel-color 21
      set plabel "current-busstop"
    ]
  ]
  ]


  if  [pcolor]  of patch round mouse-xcor (round( mouse-ycor) - 1) = white
  [
  ask current-busstop
  [
    ask patch-at 0 0
    [
      set pcolor 24
    ]
    ask patch-at 1 0
    [
      set plabel-color 21
      set plabel "current-busstop"
    ]
  ]
  ]

  if [ pcolor ] of patch (round ( mouse-xcor) - 1)  round mouse-ycor = white
  [
  ask current-busstop
  [
    ask patch-at 0 0
    [
      set pcolor 24
    ]
    ask patch-at 1 0
    [
      set plabel-color 21
      set plabel "current-busstop"
    ]
  ]
  ]


  if [ pcolor ] of patch round  mouse-xcor  (round (mouse-ycor) + 1) = white
  [

  ask current-busstop
  [

    ask patch-at 0 0
    [
      set pcolor 24
    ]
    ask patch-at 1 0

    [
      set plabel-color 21
      set plabel "current-busstop"
    ]
  ]
  ]
  ]

  [
    user-message (word "a bus-stop can't be placed on road or road-divider or  very far from road")stop
  ];
  if [ pcolor ] of patch round  mouse-xcor  (round (mouse-ycor) + 1) = 45 or [ pcolor ] of patch (round ( mouse-xcor) - 1)  round mouse-ycor = 45 or [pcolor]  of patch round mouse-xcor (round( mouse-ycor) - 1) = 45 or [ pcolor ] of patch (round (mouse-xcor) + 1) round mouse-ycor = 45
  [
    user-message (word "a bus-stop can't be placed beside another bus-stop")stop
  ]

  ifelse [ pcolor ] of patch round  mouse-xcor  (round (mouse-ycor) + 1) = 15 or [ pcolor ] of patch (round ( mouse-xcor) - 1)  round mouse-ycor = 15 or [pcolor]  of patch round mouse-xcor (round( mouse-ycor) - 1) = 15 or [ pcolor ] of patch (round (mouse-xcor) + 1) round mouse-ycor = 15
  [
    user-message (word "a bus-stop can't be placed beside a traffic signal")stop
  ]
  [
    if [ pcolor ] of patch round  mouse-xcor  (round (mouse-ycor) + 1) = 55 or [ pcolor ] of patch (round ( mouse-xcor) - 1)  round mouse-ycor = 55 or [pcolor]  of patch round mouse-xcor (round( mouse-ycor) - 1) = 55 or [ pcolor ] of patch (round (mouse-xcor) + 1) round mouse-ycor = 55
  [
    user-message (word "a bus-stop can't be placed beside a traffic signal")stop
  ]
  ]

end

to unlabel-current
  ask current-light
  [
    ask patch-at -1 1
    [
      set plabel ""
    ]
  ]
end

to unlabel-busstop
  if[pcolor] of patch round mouse-xcor round mouse-ycor = 24
  [
  ask current-busstop
  [
    ask patch-at 0 0
    [
      set pcolor 38
    ]
    ask patch-at 1 0
    [
       set plabel ""
    ]
    set pcolor 38
  ]
  ]
end

to set-signals
  ask intersections with [auto? and phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [
    set green-light-up? (not green-light-up?)
    set-signal-colors
  ]
end

to set-busstops
  ask intersections with [phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [

    ask patch-at -3 0 [ set pcolor 45 ]

  ]
  ask intersections-west with [phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [

    ask patch-at 3 0 [ set pcolor 45 ]

  ]
  ask intersections-south with [phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [
    ask patch-at 0 -5 [ set pcolor 45 ]

  ]
  ask intersections-north with [phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [
    ask patch-at 0 5 [ set pcolor 45 ]

  ]
end

to set-busstop
  ask roads with [phase = floor ((my-phase * ticks-per-cycle) / 100)]
  [
    ask patch-at -3 0 [ set pcolor 45 ]
  ]
end


to set-signal-colors
  ifelse power?
  [
    ifelse green-light-up?
    [
      ask patch-at -1 0 [ set pcolor red
        set intersection? true
        ]
      ask patch-at 0 -1 [ set pcolor green
        set intersection? true
        ]
      ask patch-at 2 3 [ set pcolor red
        set intersection? true
        ]
      ask patch-at 3 2 [ set pcolor green
        set intersection? true
        ]

    ]
    [
      ask patch-at -1 0 [ set pcolor green
        set intersection? true
        ]
      ask patch-at 0 -1 [ set pcolor red
        set intersection? true
        ]
      ask patch-at 2 3 [ set pcolor green
        set intersection? true
        ]
      ask patch-at 3 2 [ set pcolor red
        set intersection? true
        ]
    ]
  ]
  [
    ask patch-at -1 0 [ set pcolor white
      set intersection? true
      ]
    ask patch-at 0 -1 [ set pcolor white
      set intersection? true
      ]
    ask patch-at 2 3 [ set pcolor white
      set intersection? true
       ]
    ask patch-at 3 2 [ set pcolor white
      set intersection? true
      ]
  ]

end

to set-car-speed
  ifelse pcolor = red
  [ set speed 0 ]
  [
    ifelse up-vehicle?
    [
      ifelse [pcolor] of patch-at -1 0 = 24 and any? (turtles-on patch-ahead 1 ) with [shape = "bus"]
      [
        set speed 0.5
        record-slowed-cardata
      ]
      [
        set-speed 0 1
      ]
    ]
    [
      ifelse [pcolor] of patch-at 0 -1 = 24 and any? (turtles-on patch-ahead 1 ) with [shape = "bus"]
      [
        set speed 0.5
        record-slowed-cardata
      ]
      [set-speed 1 0 ]

    ]
  ]
end

to set-oppositecar-speed


     ifelse pcolor = red
     [set speed 0]
     [

    ifelse down-vehicle?
    [
      ifelse [pcolor] of patch-at 1 0 = 24 and (any? (turtles-on patch-ahead -1 ) with [shape = "other-bus"])
      [
        set speed 0.5
        record-slowed-cardata
      ]
      [
        set-oppositecarspeed 0 -1
      ]
    ]
    [
       ifelse [pcolor] of patch-at 0 1 = 24 and (any? (turtles-on patch-ahead -1 ) with [shape = "other-bus"])
      [
        set speed 0.5
        record-slowed-cardata
      ]
       [
       set-oppositecarspeed -1 0
       ]
     ]

  ]
end

to set-bus-speed
  ifelse pcolor = 45
  [set speed 0]
  [
    ifelse up-vehicle?
    [
      ifelse [pcolor] of patch-at -1 0 = 24
      [
        set speed 0.5
        record-slowed-busdata
      ]
      [
        set-busspeed 0 1
      ]
    ]
    [
      ifelse [pcolor] of patch-at 0 -1 = 24
      [
        set speed 0.5
        record-slowed-busdata
      ]
      [set-busspeed 1 0 ]

    ]
  ]

  ifelse pcolor = red
  [ set speed 0 ]
  [
    ifelse up-vehicle?
    [
      ifelse [pcolor] of patch-at -1 0 = 24
      [
        set speed 0.5
        record-slowed-busdata

      ]
      [
        set-busspeed 0 1
      ]
    ]
    [
      ifelse [pcolor] of patch-at 0 -1 = 24
      [
        set speed 0.5
        record-slowed-busdata
      ]
      [set-busspeed 1 0 ]

    ]
  ]

end


to set-oppositebus-speed

  ifelse pcolor = 45
  [set speed 0]
  [
    ifelse down-vehicle?
    [
      ifelse [pcolor] of patch-at 1 0 = 24
      [
        set speed 0.5
        record-slowed-busdata
      ]
      [
        set-oppositebusspeed 0 -1
      ]
    ]
    [
       ifelse [pcolor] of patch-at 0 1 = 24
      [
        set speed 0.5
        record-slowed-busdata
      ]
       [
       set-oppositebusspeed -1 0
       ]
     ]
  ]


  ifelse pcolor = red
  [ set speed 0 ]
  [
    ifelse down-vehicle?
    [
      ifelse [pcolor] of patch-at 1 0 = 24
      [
        set speed 0.5
        record-slowed-busdata
      ]
      [
        set-oppositebusspeed 0 -1
      ]
    ]
    [
       ifelse [pcolor] of patch-at 0 1 = 24
      [
        set speed 0.5
        record-slowed-busdata
      ]
       [
       set-oppositebusspeed -1 0
       ]
     ]
  ]

end


to set-speed [ delta-x delta-y ]
  let turtles-ahead turtles-at delta-x delta-y
  ifelse any? turtles-ahead
  [
    ifelse (any? (turtles-ahead with [ up-vehicle? != [up-vehicle?] of myself]))
    [
      set speed 0
    ]
    [
      set speed [speed] of one-of turtles-ahead
      slow-down
    ]
  ]
  [ speed-up ]
end


to set-oppositecarspeed [ delta-x delta-y ]

  let turtles-ahead turtles-at delta-x delta-y

  ifelse any? turtles-ahead
  [
    ifelse any? (turtles-ahead with [ down-vehicle? != [down-vehicle?] of myself])
    [
      set speed 0
    ]
    [
      set speed [speed] of one-of turtles-ahead
      slow-down
    ]
  ]
    [ speed-up ]
end


to set-busspeed [ delta-x delta-y ]

  let turtles-ahead turtles-at delta-x delta-y

  ifelse any? turtles-ahead
  [
    ifelse any? (turtles-ahead with [ up-vehicle? != [up-vehicle?] of myself])
    [
      set speed 0
    ]
    [
      set speed [speed] of one-of turtles-ahead
      slow-down
    ]
  ]
  [ speed-up ]
end


to set-oppositebusspeed [ delta-x delta-y ]

  let turtles-ahead turtles-at delta-x delta-y


  ifelse any? turtles-ahead
  [
    ifelse any? (turtles-ahead with [ down-vehicle? != [down-vehicle?] of myself])
    [
      set speed 0
    ]
    [
      set speed [speed] of one-of turtles-ahead
      slow-down
    ]
  ]
  [speed-up ]
end

to slow-down
  ifelse speed <= 0
  [ set speed 0 ]
  [ set speed speed - acceleration ]
end


to speed-up
  ifelse speed > speed-limit
  [ set speed speed-limit ]
  [ set speed speed + acceleration ]
end


to opposite-slow-down
  ifelse speed <= 0
  [ set speed 0 ]
  [ set speed speed - acceleration ]
end


to opposite-speed-up
  ifelse speed > speed-limit
  [ set speed speed-limit ]
  [ set speed speed + acceleration ]
end


to set-car-color
  ifelse speed < (speed-limit / 2)
  [ ask newcars [ set color blue ] ]
  [ ask newcars [set color blue - 2] ]
end

to set-oppositecar-color
  ifelse speed < (speed-limit / 2)
  [ ask oppositecars [ set color red ] ]
  [ ask oppositecars [set color red + 3 ] ]
end

to set-bus-color
  ifelse speed < (speed-limit / 2)
  [ ask newbuses [ set color magenta ]]
  [ ask newbuses [ set color 95]]
end

to set-oppositebus-color
  ifelse speed < (speed-limit / 2)
  [ ask oppositebuses [ set color  55]]
  [ ask oppositebuses [ set color 25 ]]
end


to record-data
  ifelse speed = 0
  [
    set num-cars-stopped num-cars-stopped + 1
    set wait-time wait-time + 1
  ]
  [ set wait-time 0 ]
end


to record-busdata
  ifelse speed = 0
  [
    set num-buses-stopped num-buses-stopped + 1
    set bus-wait-time bus-wait-time + 1
  ]
  [ set bus-wait-time 0 ]
end


to record-slowed-cardata
  ifelse speed = 0.5
  [
    set num-cars-slowed num-cars-slowed + 1
    set wait-time wait-time + 0.5
  ]
  [ set wait-time 0 ]
end


to record-slowed-busdata
  ifelse speed = 0.5
  [
    set num-buses-slowed num-buses-slowed + 1
    set bus-wait-time bus-wait-time + 0.5
  ]
  [ set bus-wait-time 0 ]
end


to change-current
  ask current-light
  [
    ifelse green-light-up? = true
    [
    set green-light-up? (not green-light-up?)

    ask patch-at 0 0
    [
      set pcolor red
    ]
    ]
    [
          set green-light-up? true
    ask patch-at 0 0
    [
      set pcolor green
    ]
    ]
  ]
end

to next-phase

  set phase phase + 1
  if phase mod ticks-per-cycle = 0
    [ set phase 0 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
325
10
740
426
-1
-1
11.0
1
12
1
1
1
0
1
1
1
-18
18
-18
18
1
1
1
ticks
30.0

PLOT
311
437
529
601
Average Wait Time of Cars
Time
Average Wait
0.0
100.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [wait-time] of turtles with [ shape = \"car\" or shape = \"othercar\"]"

PLOT
743
211
959
376
Average Speed of Cars
Time
Average Speed
0.0
100.0
0.0
1.0
true
false
"set-plot-y-range 0 speed-limit" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [speed] of turtles with [ shape = \"car\" or shape = \"othercar\"]"

SLIDER
108
35
205
68
grid-size-y
grid-size-y
1
4
3.0
1
1
NIL
HORIZONTAL

SLIDER
12
35
106
68
grid-size-x
grid-size-x
1
4
2.0
1
1
NIL
HORIZONTAL

SWITCH
1217
70
1312
103
power?
power?
0
1
-1000

SLIDER
12
71
293
104
num-cars
num-cars
1
400
90.0
1
1
NIL
HORIZONTAL

PLOT
748
382
962
546
Stopped Cars
Time
Stopped Cars
0.0
100.0
0.0
100.0
true
false
"set-plot-y-range 0 num-cars" ""
PENS
"default" 1.0 0 -16777216 true "" "plot num-cars-stopped"

BUTTON
221
184
285
217
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
208
35
292
68
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
11
177
165
210
speed-limit
speed-limit
0
1
0.9
0.1
1
NIL
HORIZONTAL

MONITOR
205
132
310
177
Current Phase
phase
3
1
11

SLIDER
11
143
165
176
ticks-per-cycle
ticks-per-cycle
1
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
146
256
302
289
current-phase
current-phase
0
99
0.0
1
1
%
HORIZONTAL

BUTTON
9
292
143
325
Change light
change-current
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
9
256
144
289
current-auto?
current-auto?
0
1
-1000

BUTTON
145
292
300
325
Select intersection
choose-current
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1206
337
1386
370
add busstop on side
choose-busstop
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
758
12
930
45
num-buses
num-buses
1
400
34.0
1
1
NIL
HORIZONTAL

BUTTON
1091
10
1239
43
remove busstop
remove-busstop
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
536
438
736
588
Average wait time of buses
Time
Average Wait
0.0
100.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [bus-wait-time] of turtles with [ shape = \"bus\" or shape = \"other-bus\" or shape = \"horizontalbus\" or shape =\"horizontalbus1\"]"

PLOT
970
213
1170
363
Average speed of buses
Time
Average speed
0.0
100.0
0.0
1.0
true
false
"set-plot-y-range 0 speed-limit" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [speed] of turtles with [ shape = \"bus\" or shape = \"other-bus\" or shape = \"horizontalbus\" or shape = \"horizontalbus1\"]"

PLOT
972
380
1172
530
stopped buses
Time
Stopped buses
0.0
100.0
0.0
100.0
true
false
"set-plot-y-range 0 num-buses" ""
PENS
"default" 1.0 0 -16777216 true "" "plot num-buses-stopped"

PLOT
750
53
950
203
slowed cars
Time
slowed cars
0.0
100.0
0.0
100.0
true
false
"set-plot-y-range 0 num-cars" ""
PENS
"default" 1.0 0 -16777216 true "" "plot  num-cars-slowed"

PLOT
969
52
1169
202
slowed buses
Time
slowed buses
0.0
100.0
0.0
100.0
true
false
"set-plot-y-range 0 num-buses" ""
PENS
"default" 1.0 0 -16777216 true "" "plot num-buses-slowed"

BUTTON
941
11
1085
44
setup-busstops
setup-busstops
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1091
11
1247
44
remove-busstops
remove-busstops
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

bus
false
0
Polygon -7500403 true true 206 285 150 285 120 285 105 270 105 30 120 15 135 15 206 15 210 30 210 270
Rectangle -16777216 true false 126 69 159 264
Line -7500403 true 135 240 165 240
Line -7500403 true 120 240 165 240
Line -7500403 true 120 210 165 210
Line -7500403 true 120 180 165 180
Line -7500403 true 120 150 165 150
Line -7500403 true 120 120 165 120
Line -7500403 true 120 90 165 90
Line -7500403 true 135 60 165 60
Rectangle -16777216 true false 174 15 182 285
Circle -16777216 true false 187 210 42
Rectangle -16777216 true false 127 24 205 60
Circle -16777216 true false 187 63 42
Line -7500403 true 120 43 207 43

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
true
0
Polygon -7500403 true true 180 15 164 21 144 39 135 60 132 74 106 87 84 97 63 115 50 141 50 165 60 225 150 285 165 285 225 285 225 15 180 15
Circle -16777216 true false 180 30 90
Circle -16777216 true false 180 180 90
Polygon -16777216 true false 80 138 78 168 135 166 135 91 105 106 96 111 89 120
Circle -7500403 true true 195 195 58
Circle -7500403 true true 195 47 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

horizontalbus
false
0
Polygon -7500403 true true 15 206 15 150 15 120 30 105 270 105 285 120 285 135 285 206 270 210 30 210
Rectangle -16777216 true false 36 126 231 159
Line -7500403 true 60 135 60 165
Line -7500403 true 60 120 60 165
Line -7500403 true 90 120 90 165
Line -7500403 true 120 120 120 165
Line -7500403 true 150 120 150 165
Line -7500403 true 180 120 180 165
Line -7500403 true 210 120 210 165
Line -7500403 true 240 135 240 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 48 187 42
Rectangle -16777216 true false 240 127 276 205
Circle -16777216 true false 195 187 42
Line -7500403 true 257 120 257 207

horizontalbus1
false
0
Polygon -7500403 true true 285 206 285 150 285 120 270 105 30 105 15 120 15 135 15 206 30 210 270 210
Rectangle -16777216 true false 69 126 264 159
Line -7500403 true 240 135 240 165
Line -7500403 true 240 120 240 165
Line -7500403 true 210 120 210 165
Line -7500403 true 180 120 180 165
Line -7500403 true 150 120 150 165
Line -7500403 true 120 120 120 165
Line -7500403 true 90 120 90 165
Line -7500403 true 60 135 60 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 210 187 42
Rectangle -16777216 true false 24 127 60 205
Circle -16777216 true false 63 187 42
Line -7500403 true 43 120 43 207

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

other-bus
false
0
Polygon -7500403 true true 206 15 150 15 120 15 105 30 105 270 120 285 135 285 206 285 210 270 210 30
Rectangle -16777216 true false 126 36 159 231
Line -7500403 true 135 60 165 60
Line -7500403 true 120 60 165 60
Line -7500403 true 120 90 165 90
Line -7500403 true 120 120 165 120
Line -7500403 true 120 150 165 150
Line -7500403 true 120 180 165 180
Line -7500403 true 120 210 165 210
Line -7500403 true 135 240 165 240
Rectangle -16777216 true false 174 15 182 285
Circle -16777216 true false 187 48 42
Rectangle -16777216 true false 127 240 205 276
Circle -16777216 true false 187 195 42
Line -7500403 true 120 257 207 257

othercar
true
0
Polygon -7500403 true true 180 285 164 279 144 261 135 240 132 226 106 213 84 203 63 185 50 159 50 135 60 75 150 15 165 15 225 15 225 285 180 285
Circle -16777216 true false 180 180 90
Circle -16777216 true false 180 30 90
Polygon -16777216 true false 80 162 78 132 135 134 135 209 105 194 96 189 89 180
Circle -7500403 true true 195 47 58
Circle -7500403 true true 195 195 58

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
