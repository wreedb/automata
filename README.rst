Automata
========

Huh?
~~~~

:strong:`automata` is a command-line application for automatically
launching programs with declarative configuration. A program like this
can be especially useful for those who use tiling Wayland compositors
and X11 window managers.

Don't XDG Autostart entries exist?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Yeah, they sure do. However they just aren't very good. They are also
often expected that they would be launched by a users' desktop environment,
which results in the many desktops having their own personal implementation
of how to handle such entries, whereas :strong:`automata` just provides a
single (yet powerful) way to do it.

Example Configuration
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: toml

   [[prog]]
   name = "swaync"
   path = "/usr/bin/swaync"

   [[prog]]
   name = "swww-daemon"
   args = ["-q"]

   [[prog]]
   name = "swhks"
   directory = "$HOME"

   [[prog]]
   name = "swhkd"
   directory = "$HOME"


How to use it in practice?
~~~~~~~~~~~~~~~~~~~~~~~~~~

Here are a few examples of how you might use it with `Niri <https://niri-wm.github.io/niri>`_ and `Hyprland <https://hypr.land>`_

.. code-block:: ini

   # ~/.config/hyprland.conf
   exec-once = automata


.. code-block:: kdl

   // ~/.config/niri/config.kdl
   spawn-at-startup "automata";
