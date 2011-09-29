/* 
 * Copyright (C) 2011 Lukas Märdian <lukasmaerdian@gmail.com>
 * 
 * This file is part of the GTA04 Tester.
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02111 USA.
 *
 */

using GTA04;

int main( string[] args )
{
    if (!Thread.supported ())
    {
        stderr.printf ("Cannot run without thread support.\n");
        return 1;
    }

    Intl.bindtextdomain( Config.GETTEXT_PACKAGE, Config.LOCALEDIR );
    Intl.bind_textdomain_codeset( Config.GETTEXT_PACKAGE, "UTF-8" );
    Intl.textdomain( Config.GETTEXT_PACKAGE );

    Gtk.init( ref args );

    /* build UI */
    var ui = new GTA04.UI();
    ui.show_all();

    /* execute tests in another thread */
    unowned Thread<void*> tester;
    var tester_data = new GTA04.Tester (ui);
    try
    {
        tester = Thread.create<void*> (tester_data.run_tests, true);
    }
    catch (ThreadError e)
    {
        stderr.printf ("Cannot start GTA04.Tester thread: %s\n", e.message);
        return 1;
    }

    Gtk.main();
    // Don't wait for GTA04.Tester thread to finish
    //tester.join ();
    return 0;
}

// vim:ts=4:sw=4:expandtab
