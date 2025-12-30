<div align="center">
  <h1>Bubblezone for Ruby</h1>
  <h4>Helper utility for <a href="https://github.com/marcoroth/bubbletea-ruby">Bubble Tea</a>, allowing easy mouse event tracking in terminal applications.</h4>

  <p>
    <a href="https://rubygems.org/gems/bubblezone"><img alt="Gem Version" src="https://img.shields.io/gem/v/bubblezone"></a>
    <a href="https://github.com/marcoroth/bubblezone-ruby/blob/main/LICENSE.txt"><img alt="License" src="https://img.shields.io/github/license/marcoroth/bubblezone-ruby"></a>
  </p>

  <p>Ruby bindings for <a href="https://github.com/lrstanley/bubblezone">lrstanley/bubblezone</a>.<br/>Track clickable regions in terminal UIs. Built for use with <a href="https://github.com/marcoroth/bubbletea-ruby">Bubble Tea</a> and <a href="https://github.com/marcoroth/lipgloss-ruby">Lipgloss</a>.</p>
</div>

## Installation

**Add to your Gemfile:**

```ruby
gem "bubblezone"
```

**Or install directly:**

```bash
gem install bubblezone
```

## Usage

### Basic Zone Marking

**Initialize the global zone manager:**

```ruby
require "bubblezone"

Bubblezone.new_global
```

**Mark a region with an ID:**

```ruby
button = Bubblezone.mark("my_button", "Click Me")
```

**Build your layout and scan to register zones:**

```ruby
layout = "Header\n#{button}\nFooter"
output = Bubblezone.scan(layout)
puts output
```

**Output:**

```
Header
Click Me
Footer
```

### Getting Zone Information

**Get zone info by ID:**

```ruby
zone = Bubblezone.get("my_button")
```

**Check zone bounds:**

```ruby
if zone
  puts "Zone bounds: (#{zone.start_x}, #{zone.start_y}) to (#{zone.end_x}, #{zone.end_y})"
end
```

### Checking Mouse Coordinates

**Get coordinates from mouse event:**

```ruby
x, y = message.x, message.y
```

**Check if coordinates are within a zone:**

```ruby
zone = Bubblezone.get("my_button")
if zone&.in_bounds?(x, y)
  puts "Button clicked!"
end
```

### Iterating Over Zones

**Iterate over all zones containing the coordinates:**

```ruby
Bubblezone.each_in_bounds(x, y) do |id, zone|
  puts "Hit zone: #{id}"
end
```

**Check if any zone contains the coordinates:**

```ruby
if Bubblezone.any_in_bounds?(x, y)
  puts "Something was clicked"
end
```

**Get the first matching zone:**

```ruby
result = Bubblezone.find_in_bounds(x, y)
if result
  id, zone = result
  puts "First hit: #{id}"
end
```

### Zone Prefixes

**Prevent ID conflicts between components:**

```ruby
class MyComponent
  def initialize
    @prefix = Bubblezone.new_prefix
  end

  def view
    items = ["Apple", "Banana", "Cherry"]
    items.map.with_index do |item, i|
      Bubblezone.mark("#{@prefix}#{i}", item)
    end.join("\n")
  end
end
```

### Manager Instances

**Create a dedicated manager:**

```ruby
manager = Bubblezone::Manager.new
```

**Use the same API as the global manager:**

```ruby
marked = manager.mark("zone_id", "Content")
output = manager.scan(marked)
zone = manager.get("zone_id")
```

**Iterate zones:**

```ruby
manager.each_in_bounds(x, y) { |id, zone| ... }
```

**Clean up when done:**

```ruby
manager.close
```

### Integration with Bubbletea

**Handle mouse clicks in a Bubbletea model:**

```ruby
require "bubbletea"
require "bubblezone"

Bubblezone.new_global

class ClickableApp
  include Bubbletea::Model

  ITEMS = ["Option A", "Option B", "Option C"]

  def initialize
    @selected = nil
    @prefix = Bubblezone.new_prefix
  end

  def init
    [self, nil]
  end

  def update(message)
    case message
    when Bubbletea::MouseMessage
      if message.release? && (message.left? || message.button == 0)
        result = Bubblezone.find_in_bounds(message.x, message.y)
        if result
          id, _zone = result
          @selected = id.sub(@prefix, "").to_i
        end
      end
      [self, nil]
    when Bubbletea::KeyMessage
      return [self, Bubbletea.quit] if message.to_s == "q"
      [self, nil]
    else
      [self, nil]
    end
  end

  def view
    lines = ITEMS.map.with_index do |item, i|
      marker = i == @selected ? "[x]" : "[ ]"
      content = "#{marker} #{item}"
      Bubblezone.mark("#{@prefix}#{i}", content)
    end

    Bubblezone.scan(lines.join("\n"))
  end
end

Bubbletea.run(ClickableApp.new, alt_screen: true, mouse_cell_motion: true)
```

### Integration with Lipgloss

**Style your content first:**

```ruby
require "lipgloss"
require "bubblezone"

Bubblezone.new_global

button_style = Lipgloss::Style.new
  .background("#7D56F4")
  .foreground("#FFFFFF")
  .padding(0, 3)
```

**Mark the fully styled content:**

```ruby
styled_button = button_style.render("Click Me")
clickable_button = Bubblezone.mark("btn", styled_button)
```

**Scan to register zones:**

```ruby
output = Bubblezone.scan(clickable_button)
```

## API Reference

### Module Methods (Global Manager)

| Method | Description |
|--------|-------------|
| `Bubblezone.new_global` | Initialize the global zone manager |
| `Bubblezone.close` | Close the global manager |
| `Bubblezone.enabled?` | Check if zone tracking is enabled |
| `Bubblezone.enabled = bool` | Enable/disable zone tracking |
| `Bubblezone.new_prefix` | Generate a unique zone ID prefix |
| `Bubblezone.mark(id, text)` | Wrap text with zone markers |
| `Bubblezone.scan(text)` | Parse zones and strip markers |
| `Bubblezone.get(id)` | Get ZoneInfo for an ID (or nil) |
| `Bubblezone.clear(id)` | Remove a stored zone |
| `Bubblezone.clear_all` | Remove all stored zones |
| `Bubblezone.zone_ids` | Get array of all tracked zone IDs |

### Iteration Methods

| Method | Description |
|--------|-------------|
| `Bubblezone.each_in_bounds(x, y) { \|id, zone\| }` | Yield each zone containing coordinates |
| `Bubblezone.any_in_bounds?(x, y)` | Check if any zone contains coordinates |
| `Bubblezone.find_in_bounds(x, y)` | Get first `[id, zone]` pair, or nil |

### Manager Class

| Method | Description |
|--------|-------------|
| `Manager.new` | Create a new zone manager |
| `#close` | Close the manager |
| `#enabled?` / `#enabled=` | Get/set enabled state |
| `#new_prefix` | Generate unique prefix |
| `#mark(id, text)` | Mark text with zone |
| `#scan(text)` | Parse and strip markers |
| `#get(id)` | Get zone info |
| `#clear(id)` | Clear specific zone |
| `#clear_all` | Clear all zones |
| `#zone_ids` | Get all zone IDs |
| `#each_in_bounds(x, y)` | Iterate matching zones |
| `#any_in_bounds?(x, y)` | Check for any match |
| `#find_in_bounds(x, y)` | Get first match |

### ZoneInfo Class

| Method | Description |
|--------|-------------|
| `#start_x`, `#start_y` | Zone start coordinates |
| `#end_x`, `#end_y` | Zone end coordinates |
| `#in_bounds?(x, y)` | Check if coordinates are within zone |
| `#zero?` | Check if zone has no position data |
| `#pos(x, y)` | Get relative position within zone |

## Important Notes

### Zone Processing is Asynchronous

The Go bubblezone library processes zones asynchronously. After calling `scan`, there may be a brief delay before zones are available via `get`. In interactive applications with Bubbletea, this is typically not an issue as mouse events occur after rendering.

### Coordinate Systems

When using `alt_screen: true` with Bubbletea, mouse coordinates are relative to (0, 0) at the top-left of the screen, matching zone coordinates exactly. Without alt screen, you may need to account for terminal scroll position.

### Order of Operations

1. Style your content with Lipgloss
2. Mark the styled content with `Bubblezone.mark`
3. Build your complete layout
4. Call `Bubblezone.scan` on the final output
5. Handle mouse events using `get` or `find_in_bounds`

## Development

**Requirements:**
- Go 1.23+
- Ruby 3.2+

**Install dependencies:**

```bash
bundle install
```

**Build the Go library and compile the extension:**

```bash
bundle exec rake compile
```

**Run tests:**

```bash
bundle exec rake test
```

**Run demos:**

```bash
./demo/clickable_alt
./demo/clickable_list
./demo/clickable_simple
./demo/full_layout
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcoroth/bubblezone-ruby.

## License

The gem is available as open source under the terms of the MIT License.

## Acknowledgments

This gem wraps [lrstanley/bubblezone](https://github.com/lrstanley/bubblezone), which provides zone tracking for terminal UIs and builds on the excellent [Charm](https://charm.sh) ecosystem, including [lipgloss](https://github.com/charmbracelet/lipgloss) and [bubbletea](https://github.com/charmbracelet/bubbletea). Charm Ruby is not affiliated with or endorsed by Charmbracelet, Inc.

---

Part of [Charm Ruby](https://charm-ruby.dev).

<a href="https://charm-ruby.dev"><img alt="Charm Ruby" src="https://marcoroth.dev/images/heros/glamorous-christmas.png" width="400"></a>

[Lipgloss](https://github.com/marcoroth/lipgloss-ruby) • [Bubble Tea](https://github.com/marcoroth/bubbletea-ruby) • [Bubbles](https://github.com/marcoroth/bubbles-ruby) • [Glamour](https://github.com/marcoroth/glamour-ruby) • [Huh?](https://github.com/marcoroth/huh-ruby) • [Harmonica](https://github.com/marcoroth/harmonica-ruby) • [Bubblezone](https://github.com/marcoroth/bubblezone-ruby) • [Gum](https://github.com/marcoroth/gum-ruby) • [ntcharts](https://github.com/marcoroth/ntcharts-ruby)

The terminal doesn't have to be boring.
