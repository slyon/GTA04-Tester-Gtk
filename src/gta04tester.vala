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

using Gtk;
using Gee;

public class GTA04.TestCase
{
    private TreeIter iter;
    private string name;
    private string status = "Pending";
    private string color = "yellow";
    private string result = "";
    private string description;
    private string untested;

    public TestCase( string name, string description, string untested )
    {
        this.name = name;
        this.description = description;
        this.untested = untested;
    }

    public void set_iter( TreeIter iter ) { this.iter = iter; }
    public string get_name() { return this.name; }
    public string get_status() { return this.status; }
    public string get_color() { return this.color; }
    public string get_result() { return this.result; }
    public string get_description() { return this.description; }
    public string get_untested() { return this.untested; }

    public void update( GTA04.UI ui, bool passed, string result="" )
    {
        if( passed )
        {
            this.status = "Passed";
            this.color = "green";
        }
        else
        {
            this.status = "Failed";
            this.color = "red";
        }
        this.result = result;
        ui.listmodel.set( iter, 0, get_name(), 1, get_status(), 2, get_color(), 3, get_result(), 4, get_description(), 5, get_untested() );
    }
}

public class GTA04.UI: Window
{
    public ListStore listmodel;
    public HashMap<string, GTA04.TestCase> testcases;

    public UI()
    {
        title = "GTA04 Tester";
        set_default_size( 700, 500 );
        set_position( WindowPosition.CENTER );
        destroy.connect( Gtk.main_quit );

        string path = GLib.Path.build_filename( Config.PKGDATADIR, "images", "icon.png", null );
        try
        {
            icon = new Gdk.Pixbuf.from_file( path );
        }
        catch ( Error e )
        {
            stderr.printf( "Could not load application icon: %s\n", e.message );
        }

        var text_view = new TextView();
        text_view.editable = false;
        text_view.cursor_visible = false;
        text_view.buffer.text = _("""1. Insert the µSD card into the GTA04 board.
2. Insert the SIM card into the GTA04 board.
3. Attach the USB cable and the headset cable.
4. Push the battery on the contacts (dont reverse the contacts!)
5. After 7 sec the power LED should first glow red, then yellow, then green. - If not: the board is broken.
6. After the "USB" entry turned green, the battery can be removed.
7. Await the test results.
8. Push the "Shutdown GTA04" button, then wait until the LED turned off and detatch the USB cable.
9. Remove the SIM card and the µSD card.""");

        testcases = new HashMap<string, GTA04.TestCase>();

        testcases.set( "usb", new TestCase( "USB", _("USB power, MMC, Linux boots, Ethernet gadget"), _("Host mode, USB charging") ) );
        //testcases.set( "cpu_id", new TestCase( "CPU-ID", _("CPU serial number (doesn't exist!)"), _("") ) );
        testcases.set( "rs232", new TestCase( "RS232", _("RS232 connection"), _("RTS, CTS") ) );
        testcases.set( "w2cbw003_wlan", new TestCase( "W2CBW003-WLAN", _("ifconfig up successful"), _("communication") ) );
        testcases.set( "w2cbw003_wlan_libertas", new TestCase( "W2CBW003-WLAN-libertas", _("WLAN power works, recognised as SDIO, driver loads"), _("communication") ) );
        testcases.set( "w2cbw0003_wlan_scan", new TestCase( "W2CBW003-WLAN-scan", _("WLAN communication (approximately)"), _("data rate, sensitivity") ) );
        //testcases.set( "w2cbw0003_wlan_mac", new TestCase( "W2CBW003-WLAN-MAC", _("MAC address WLAN"), _("") ) );
        testcases.set( "w2cbw0003_bt", new TestCase( "W2CBW003-BT", _("hciconfig hci0 up successful"), _("communication") ) );
        testcases.set( "w2cbw0003_bt_scan", new TestCase( "W2CBW003-BT-scan", _("Bluetooth communication (approximately)"), _("PCM, data rate, sensitivity") ) );
        //testcases.set( "w2cbw0003_bt_mac", new TestCase( "W2CBW003-BT-MAC", _("MAC address bluetooth"), _("") ) );
        testcases.set( "gtm601", new TestCase( "GTM601", _("UMTS modul recognized at USB port"), _("radio, PCM, AT commands") ) );
        testcases.set( "gtm601_imei", new TestCase( "GTM601-IMEI", _("UMTS modul reacts to 'AT+CGSN' command"), _("IMSI, phone number, IP address") ) );
        //testcases.set( "gtm601_wwan", new TestCase( "GTM601-WWAN", _("UMTS modul connects to 2G/3G"), _("") ) );
        //testcases.set( "gtm601_phone", new TestCase( "GTM601-Phone", _("UMTS modul places a test call"), _("") ) );
        testcases.set( "w2sg0004", new TestCase( "W2SG0004", _("GPS chip responds with NMEA"), _("sensitivity, antenna switch") ) );
        testcases.set( "bmp085", new TestCase( "BMP085", _("Barometer reacts"), _("if data is useful") ) );
        testcases.set( "itg3200", new TestCase( "ITG3200", _("Gyroscope reacts"), _("if data is useful") ) );
        testcases.set( "si47xx", new TestCase( "Si47xx", _("FM-TRX responds at I2C"), _("if data is useful") ) );
        testcases.set( "tsc2007", new TestCase( "TSC2007", _("Touch controller reacts"), _("if data is useful") ) );
        testcases.set( "bma180", new TestCase( "BMA180", _("Accelerometer reacts"), _("if data is useful") ) );
        testcases.set( "hmc5883l", new TestCase( "HMC5883L", _("Compass reacts at I2C"), _("if data is useful") ) );
        testcases.set( "tca6507", new TestCase( "TCA6507", _("LED controller responds at I2C"), _("if data is useful") ) );
        testcases.set( "tps61050", new TestCase( "TPS61050", _("Torch/Flash responds at I2C"), _("if data is useful") ) );
        testcases.set( "ov9655", new TestCase( "OV9655", _("Camera modul responds at I2C"), _("if data is useful") ) );
        testcases.set( "m24lr64", new TestCase( "M24LR64", _("RFID EEPROM responds at I2C"), _("if data is useful") ) );
        testcases.set( "lis302", new TestCase( "LIS302", _("Accelerometer responds at I2C"), _("if data is useful") ) );

        var view = new TreeView();
        listmodel = new ListStore( 6, typeof(string), typeof(string), typeof(string), typeof(string), typeof(string), typeof(string) );
        view.set_model( listmodel );

        var cell = new CellRendererText();
        cell.set( "background_set", true );
        view.insert_column_with_attributes( -1, _("Function"), new CellRendererText(), "text", 0 );
        view.insert_column_with_attributes( -1, _("Status"), cell, "text", 1, "background", 2 );
        view.insert_column_with_attributes( -1, _("Value"), new CellRendererText(), "text", 3 );
        view.insert_column_with_attributes( -1, _("Description"), new CellRendererText(), "text", 4 );
        view.insert_column_with_attributes( -1, _("Untested"), new CellRendererText(), "text", 5 );

        TreeIter iter;
        foreach( var tcase in testcases.values )
        {
            listmodel.append( out iter );
            tcase.set_iter( iter );
            listmodel.set( iter, 0,tcase.get_name(), 1,tcase.get_status(), 2,tcase.get_color(), 3,tcase.get_result(), 4,tcase.get_description(), 5,tcase.get_untested() );
        }

        var save_btn = new Button.with_label( _("Save") );
        var shutdown_btn = new Button.with_label( _("Shutdown GTA04") );
        var print_btn = new Button.with_label( _("Print Report/Label") );
        save_btn.clicked.connect ( onSaveBtnClicked );
        shutdown_btn.clicked.connect ( onShutdownBtnClicked );
        print_btn.clicked.connect ( onPrintBtnClicked );
        var hbox = new HBox( true, 0 );
        hbox.add( save_btn );
        hbox.add( shutdown_btn );
        hbox.add( print_btn );

        var vbox = new VBox( false, 0 );
        vbox.add( text_view );
        vbox.add( view );
        vbox.add( hbox );
        this.add( vbox );
    }

    private void onSaveBtnClicked()
    {
        // TODO: fill me
        stdout.printf( "onSaveBtnClicked()\n" );
    }

    private void onShutdownBtnClicked()
    {
        // TODO: fill me
        stdout.printf( "onShutdownBtnClicked()\n" );
    }

    private void onPrintBtnClicked()
    {
        // TODO: fill me
        stdout.printf( "onPrintBtnClicked()\n" );
    }
}

class GTA04.Tester {
    GTA04.UI ui;

    public Tester (GTA04.UI ui) {
        this.ui = ui;
    }

    /* Run all testcases, one after another */
    public void* run_tests () {
        usb();
        gtm601();
        gtm601_imei();
        return null;
    }

    /* Test: USB */
    private bool usb()
    {
        var ip = "192.168.0.202";
        var tcase = ui.testcases.get( "usb" );
        int res;
        // wait until a device is attatched
        while( true )
        {
            res = Posix.system( @"ping -c 1 -t 1 $ip > /dev/null" );
            if( res == 0 )
            {
                tcase.update( ui, true, _(@"found device: $ip") );
                return true;
            }
            Posix.sleep( 1 );
        }
    }

    /* Test: GTM601 */
    private bool gtm601()
    {
        // TODO: this is just a test, which returns after waiting for 1 sec.
        Posix.sleep( 1 );
        //var res = Posix.system( @"echo GTM601-Test" );
        var tcase = ui.testcases.get( "gtm601" );
        tcase.update( ui, true, "Test..." );
        return true;
    }

    /* Test: GTM601-IMEI */
    private bool gtm601_imei()
    {
        // TODO: this is just a test, which reads an existing file on a device and passes the output to our GUI
        var tcase = ui.testcases.get( "gtm601_imei" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 'cat /media/internal/test-imei' > /tmp/IMEI" );
        if( res == 0 )
        {
            var file = File.new_for_path ("/tmp/IMEI");
            try
            {
                var dis = new DataInputStream (file.read ());
                string line = dis.read_line( null );
                tcase.update( ui, true, line );
            }
            catch ( Error e )
            {
                stderr.printf("%s\n", e.message);
            }
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }
}

// vim:ts=4:sw=4:expandtab