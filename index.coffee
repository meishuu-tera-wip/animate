Slash = require 'slash'

$c = require './characters'
for k, v of $c
  v.details = new Buffer v.details
  v.details2 = new Buffer v.details2

module.exports = class Animate
  constructor: (dispatch) ->
    slash = new Slash dispatch

    active = false
    here = {}

    slash.on 'anim', (args) ->
      args = args.split ' '
      switch args[0].toLowerCase()
        when 'on'
          active = true
          slash.print '[Animate] Enabled.'
        when 'off'
          active = false
          slash.print '[Animate] Disabled.'
        when 'loc'
          slash.print "[Animate] X = #{here.x || 0}, Y = #{here.y || 0}, Z = #{here.z || 0}, w = #{here.w || 0}"

        when '1'
          meishu = $c.meishu
          dispatch.toClient 'sAttackStart',
            source: meishu.cid
            x: meishu.x
            y: meishu.y
            z: meishu.z
            w: meishu.w
            model: meishu.model
            skill: 30100 | 0x04000000
            stage: 0
            speed: 0.02
            id: 1
            unk: 1.0
          setTimeout (->
            selsie = $c.selsie
            dispatch.toClient 'sAttackStart',
              source: selsie.cid
              x: selsie.x
              y: selsie.y
              z: selsie.z
              w: selsie.w
              model: selsie.model
              skill: 180100 | 0x04000000
              stage: 0
              speed: 0.01
              id: 1
              unk: 1.0
          ), 10000

        when 'spawn'
          name = args[1].toLowerCase()
          char = $c[name]
          if !char?
            slash.print 'character "' + name + '" not found'
          else
            slash.print 'dispensing ' + name
            char.x = here.x
            char.y = here.y
            char.z = here.z
            char.w = here.w
            char.weaponEnchant = 15
            dispatch.toClient 'sPlayerInfo', char

        when 'hide'
          name = args[1].toLowerCase()
          char = $c[name]
          if !char?
            slash.print 'character "' + name + '" not found'
          else
            slash.print 'hiding ' + name
            dispatch.toClient 'sAbnormalAdd',
              target: char.cid
              source: char.cid
              id: 811060
              duration: 10 * 60 * 1000
              unk: 0
              stacks: 1

        when 'show'
          name = args[1].toLowerCase()
          char = $c[name]
          if !char?
            slash.print 'character "' + name + '" not found'
          else
            slash.print 'showing ' + name
            dispatch.toClient 'sAbnormalRemove',
              target: char.cid
              id: 811060

        when 'glow'
          name = args[1].toLowerCase()
          glow = parseInt args[2]
          char = $c[name]
          if !char?
            slash.print 'character "' + name + '" not found'
          else if isNaN glow
            slash.print 'glow "' + args[2] + '" is not a number'
          else
            slash.print "setting #{name}'s glow to +#{glow}"
            dispatch.toClient 'sPlayerOutfit',
              id: char.cid
              weapon: char.weapon
              chest: char.chest
              gloves: char.gloves
              boots: char.boots
              innerwear: char.inner
              head: char.head
              face: char.face
              weaponModel: char.weaponModel
              chestModel: char.chestModel
              glovesModel: char.glovesModel
              bootsModel: char.bootsModel
              weaponDye: char.weaponDye
              chestDye: char.chestDye
              glovesDye: char.glovesDye
              bootsDye: char.bootsDye
              unk1: char.unk25
              unk2: char.unk26a
              unk3: char.unk26b
              unk4: char.unk26c
              weaponEnchant: glow
              hairAdornment: char.hairAdornment
              mask: char.mask
              back: char.back
              weaponSkin: char.weaponSkin
              costume: char.costume
              costumeDye: char.costumeDye
              enable: 1

        when 'skill'
          name = args[1].toLowerCase()
          char = $c[name]
          skill = parseInt args[2]
          speed = parseFloat args[3]
          if !char?
            slash.print 'character "' + name + '" not found'
          else if isNaN skill
            slash.print 'skill "' + args[2] + '" is not a number'
          else if isNaN speed
            slash.print 'speed "' + args[2] + '" is not a number'
          else
            slash.print 'animating ' + name
            dispatch.toClient 'sAttackStart',
              source: char.cid
              x: char.x
              y: char.y
              z: char.z
              w: char.w
              model: char.model
              skill: skill | 0x04000000
              stage: 0
              speed: speed
              id: 1
              unk: 1.0

        when 'unload'
          name = args[1].toLowerCase()
          char = $c[name]
          if !char?
            slash.print 'character "' + name + '" not found'
          else
            slash.print 'unloading ' + name
            dispatch.toClient 'sPlayerUnload',
              target: char.cid
              unk: 0
      return

    dispatch.hook 'sPlayerInfo', (event) ->
      return false if active

    dispatch.hook 'sNpcInfo', (event) ->
      return false if active

    dispatch.hook 'cUseSkill', (event) ->
      return #false if active

    dispatch.hook 'cPlayerLocation', (event) ->
      here =
        x: event.x1
        y: event.y1
        z: event.z1
        w: event.w

      return false if active
