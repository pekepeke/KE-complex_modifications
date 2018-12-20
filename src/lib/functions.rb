#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'json'
require_relative './karabiner.rb'

def from(key_code, mandatory_modifiers = [], optional_modifiers = [])
  data = {}
  data['key_code'] = key_code

  mandatory_modifiers.each do |m|
    data['modifiers'] = {} if data['modifiers'].nil?
    data['modifiers']['mandatory'] = [] if data['modifiers']['mandatory'].nil?
    data['modifiers']['mandatory'] << m
  end

  optional_modifiers.each do |m|
    data['modifiers'] = {} if data['modifiers'].nil?
    data['modifiers']['optional'] = [] if data['modifiers']['optional'].nil?
    data['modifiers']['optional'] << m
  end
  data
end

def to(events)
  data = []

  events.each do |e|
    d = {}
    d['key_code'] = e[0]
    e[1].nil? || d['modifiers'] = e[1]

    data << d
  end
  data
end

def each_key(source_keys_list: :source_keys_list, dest_keys_list: :dest_keys_list, from_mandatory_modifiers: [], from_optional_modifiers: [], to_pre_events: [], to_modifiers: [], to_post_events: [], conditions: [], as_json: false)
  data = []
  source_keys_list.each_with_index do |from_key, index|
    to_key = dest_keys_list[index]
    d = {}
    d['type'] = 'basic'
    d['from'] = _from(from_key, from_mandatory_modifiers, from_optional_modifiers)

    # Compile list of events to add to "to" section
    events = []

    to_pre_events.each do |e|
      events << e
    end

    events << if to_modifiers[0].nil?
                [to_key]
              else
                [to_key, to_modifiers]
              end

    to_post_events.each do |e|
      events << e
    end

    d['to'] = JSON.parse(to(events))

    if conditions.any?
      d['conditions'] = []
      conditions.each do |c|
        d['conditions'] << c
      end
    end
    data << d
  end

  if as_json
    JSON.generate(data)
  else
    data
  end
end

def frontmost_application(type, app_aliases)
  app_aliases.is_a?(Enumerable) || app_aliases = [app_aliases]

  # JSON.generate(Karabiner.frontmost_application(type, app_aliases))
  Karabiner.frontmost_application(type, app_aliases)
end

def frontmost_application_if(app_aliases)
  frontmost_application('frontmost_application_if', app_aliases)
end

def frontmost_application_unless(app_aliases)
  frontmost_application('frontmost_application_unless', app_aliases)
end

def generate_vi_mode(trigger_key)
  [
    generate_vi_mode_single_rule("j", "down_arrow", [], trigger_key),
    generate_vi_mode_single_rule("k", "up_arrow", [], trigger_key),
    generate_vi_mode_single_rule("h", "left_arrow", [], trigger_key),
    generate_vi_mode_single_rule("l", "right_arrow", [], trigger_key),
    generate_vi_mode_single_rule("f", "fn", [], trigger_key),
    generate_vi_mode_single_rule("b", "left_arrow", ["left_option"], trigger_key),
    generate_vi_mode_single_rule("w", "right_arrow", ["left_option"], trigger_key),
    generate_vi_mode_single_rule("0", "a", ["left_control"], trigger_key),
    generate_vi_mode_single_rule("4", "e", ["left_control"], trigger_key),
  ].flatten
end

def generate_vi_visual_mode(trigger_key)
  [
    generate_vi_visual_mode_single_rule("j", "down_arrow", ["left_shift"], trigger_key),
    generate_vi_visual_mode_single_rule("k", "up_arrow", ["left_shift"], trigger_key),
    generate_vi_visual_mode_single_rule("h", "left_arrow", ["left_shift"], trigger_key),
    generate_vi_visual_mode_single_rule("l", "right_arrow", ["left_shift"], trigger_key),
    generate_vi_visual_mode_single_rule("b", "left_arrow", ["left_shift", "left_option"], trigger_key),
    generate_vi_visual_mode_single_rule("w", "right_arrow", ["left_shift", "left_option"], trigger_key),
    generate_vi_visual_mode_single_rule("0", "left_arrow", ["left_shift", "left_command"], trigger_key),
    generate_vi_visual_mode_single_rule("4", "right_arrow", ["left_shift", "left_command"], trigger_key),
    generate_vi_visual_mode_single_rule("open_bracket", "up_arrow", ["left_shift", "left_option"], trigger_key),
    generate_vi_visual_mode_single_rule("close_bracket", "down_arrow", ["left_shift", "left_option"], trigger_key),
  ].flatten
end

def generate_vi_mode_single_rule(from_key_code, to_key_code, to_modifier_key_code_array, trigger_key)
  [
    {
      "type" => "basic",
      "from" => {
        "key_code" => from_key_code,
        "modifiers" => { "optional" => ["any"] },
      },
      "to" => [
        {
          "key_code" => to_key_code,
          "modifiers" => to_modifier_key_code_array
        },
      ],
      "conditions" => [
        Karabiner.variable_if('vi_mode', 1),
      ]
    },

    {
      "type" => "basic",
      "from" => {
        "simultaneous" => [
          { "key_code" => trigger_key },
          { "key_code" => from_key_code },
        ],
        "simultaneous_options" => {
          "key_down_order" => "strict",
          "key_up_order" => "strict_inverse",
          "detect_key_down_uninterruptedly" => true,
          "to_after_key_up" => [
            Karabiner.set_variable("vi_mode", 0),
          ],
        },
        "modifiers" => { "optional" => ["any"] },
      },
      "to" => [
        Karabiner.set_variable("vi_mode", 1),
        {
          "key_code" => to_key_code,
          "modifiers" => to_modifier_key_code_array
        }
      ]
    }
  ]
end

def generate_vi_visual_mode_single_rule(from_key_code, to_key_code, to_modifier_key_code_array, trigger_key)
  [
    {
      "type" => "basic",
      "from" => {
        "key_code" => from_key_code,
        "modifiers" => { "optional" => ["any"] },
      },
      "to" => [
        {
          "key_code" => to_key_code,
          "modifiers" => to_modifier_key_code_array
        },
      ],
      "conditions" => [
        Karabiner.variable_if("vi_visual_mode", 1),
      ]
    },

    {
      "type" => "basic",
      "from" => {
        "simultaneous" => [
          { "key_code" => trigger_key },
          { "key_code" => from_key_code },
        ],
        "simultaneous_options" => {
          "key_down_order" => "strict",
          "key_up_order" => "strict_inverse",
          "detect_key_down_uninterruptedly" => true,
          "to_after_key_up" => [
            Karabiner.set_variable("vi_visual_mode", 0),
          ],
        },
        "modifiers" => { "optional" => ["any"] },
      },
      "to" => [
        Karabiner.set_variable("vi_visual_mode", 1),
        {
          "key_code" => to_key_code,
          "modifiers" => to_modifier_key_code_array,
        },
      ],
      "conditions" => [
        Karabiner.frontmost_application_unless(["terminal", "vi"]),
      ]
    }
  ]
end

__END__
