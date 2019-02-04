#!/usr/bin/env ruby

# You can generate json by executing the following command on Terminal.
#
# $ ruby ./personal_pekepeke.json.erb
#

require 'json'
require_relative '../lib/karabiner.rb'
require_relative '../lib/functions.rb'

def main
  puts JSON.pretty_generate(
    'title' => 'Personal rules (@pekepeke)',
    'rules' => [
      rule_backslash,
      rule_terminal,
    ] + rules_excel + rules_app
  )
end

def rule_backslash
  {
    'description' => 'Underscore(Ro) to Backslash(\) (except VM, RDC)',
    'manipulators' =>
    [
      {
        "from": from('international1'),
        "to": to([['international3', ['option']]]),
        "type": "basic",
        'conditions' => [
          Karabiner.frontmost_application_unless(%w[remote_desktop virtual_machine]),
        ],
      },
      {
        "from": from('international1', ['shift']),
        "to": to([['international1']]),
        "type": "basic",
        'conditions' => [
          Karabiner.frontmost_application_unless(%w[remote_desktop virtual_machine]),
        ],
      },
      {
        "from": from('international3'),
        "to": to([['international3', ['option']]]),
        "type": "basic",
        'conditions' => [
          Karabiner.frontmost_application_unless(%w[remote_desktop virtual_machine]),
        ],
      },
      {
        "from": from('international3', ['option']),
        "to": to([['international3']]),
        "type": "basic",
        'conditions' => [
          Karabiner.frontmost_application_unless(%w[remote_desktop virtual_machine]),
        ],
      },
    ]
  }
end

def rule_terminal
  {
    'description' => 'LeaveInsMode with EISUU(Terminal)',
    'manipulators' =>
    [from("[", ["control"]), from('escape')].map { |from_key|
      {
        "from": from_key,
        "to": to([['escape'], ['japanese_eisuu']]),
        "type": "basic",
        "conditions" => [
          Karabiner.frontmost_application_if(%w[terminal vi]),
          Karabiner.input_source_if([{'language' => 'ja'}]),
        ],
      }
    } +
    [
    ]
  }
end

def rules_excel
  [{
    'description' => 'Excel Key Mappings',
    'manipulators' => [
      {
        "from": from("j", ["control"]),
        "to": to([['return_or_enter', ['option', 'command']]]),
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_if(%w[excel]), ]
      }, {
        "from": from("m", ["control"]),
        "to":  to([['return_or_enter', ['option', 'command']]]),
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_if(%w[excel]), ]
      }, {
        "from": from("return_or_enter", ["control", 'shift']),
        "to":  to([['f10', ['shift']]]),
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_if(%w[excel]), ]
      }, {
        "from": from("f4", ["control", 'shift']),
        "to":  to([['y', ['control']]]),
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_if(%w[excel]), ]
      }, {
        "from": from("command_left", []),
        "to":  to([['f10', ['shift']]]),
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_if(%w[excel]), ]
      },
    ]
  }, {
    'description' => 'Extended Excel Key Mappings',
    'manipulators' => [
      {
        "from": from("a", ["control"]),
        "to": to([['home']]),
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_if(%w[excel]), ]
      }, {
        "from": from("e", ["control"]),
        "to": to([['end']]),
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_if(%w[excel]), ]
      },
    ]
  }]
end

def rules_app
  [{
    'description' => 'Specific App Key Mappings',
    'manipulators' => [
      {
        "from": from("1", ['option', 'command']),
        "to": [{
          'shell_command': "osascript -e 'tell app \"MacVim\"' -e 'activate' -e end"
        }],
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_unless(%w[macvim]), ]
      }, {
        "from": from("2", ['option', 'command']),
        "to": [{
          'shell_command': "osascript -e 'tell app \"iTerm2\"' -e 'activate' -e end"
        }],
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_unless(%w[terminal]), ]
      }, {
        "from": from("3", ['option', 'command']),
        "to": [{
          'shell_command': "osascript -e 'tell app \"Google Chrome\"' -e 'activate' -e end"
        }],
        "type": "basic",
        "conditions" => [ Karabiner.frontmost_application_unless(%w[browser]), ]
      }
    ]
  }]
end

main
