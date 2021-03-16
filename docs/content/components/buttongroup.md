---
title: ButtonGroup
status: Alpha
source: https://github.com/primer/view_components/tree/main/app/components/primer/button_group_component.rb
storybook: https://primer.style/view-components/stories/?path=/story/primer-button-group-component
---

import Example from '../../src/@primer/gatsby-theme-doctocat/components/example'

<!-- Warning: AUTO-GENERATED file, do not edit. Add code comments to your Ruby instead <3 -->

Use ButtonGroupComponent to render a series of buttons.

## Examples

### Default

<Example src="<div class='BtnGroup '>    <button type='button' class='btn BtnGroup-item '>Default</button>    <button button_type='primary' type='button' class='btn BtnGroup-item '>Primary</button>    <button button_type='danger' type='button' class='btn BtnGroup-item '>Danger</button>    <button button_type='outline' type='button' class='btn BtnGroup-item '>Outline</button>    <button type='button' class='btn my-class BtnGroup-item '>Custom class</button></div>" />

```erb
<%= render(Primer::ButtonGroupComponent.new) do |component|
  component.button { "Default" }
  component.button(button_type: :primary) { "Primary" }
  component.button(button_type: :danger) { "Danger" }
  component.button(button_type: :outline) { "Outline" }
  component.button(classes: "my-class") { "Custom class" }
end %>
```

## Arguments

| Name | Type | Default | Description |
| :- | :- | :- | :- |
| `system_arguments` | `Hash` | N/A | [System arguments](/system-arguments) |

## Slots

### `Buttons`

Required list of buttons to be rendered.

| Name | Type | Default | Description |
| :- | :- | :- | :- |
| `kwargs` | `Hash` | N/A | The same arguments as [Button](/components/button). |
