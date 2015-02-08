/* 
 * Copyright (C) 2011-2015 Lukas Märdian <luk@slyon.de>
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
        set_default_size( 700, 500 );

        Gtk.HeaderBar header = new Gtk.HeaderBar();
        header.set_title ("GTA04 Tester");
        header.set_subtitle ("Test your phones functionallity.");
        header.show_close_button = true;
        set_titlebar(header);

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
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; shutdown -h now;'" );
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
        bmp085();
        itg3200();
        bma180();
        lis302();
        si47xx();
        tsc2007();
        hmc5883l();
        tca6507();
        tps61050();
        ov9655();
        m24lr64();
        rs232();
        w2sg0004();
        _init_wlan_bt();
        w2cbw003_wlan();
        //w2cbw003_bt();
        stdout.printf( @"Done.\n" );
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
                Posix.sleep( 5 );
                return true;
            }
            Posix.sleep( 1 );
        }
    }

    /* Test: GTM601 */
    private bool gtm601()
    {
        var tcase = ui.testcases.get( "gtm601" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; lsusb' | fgrep '0af0:8800 Option'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false, "" );
            return false;
        }
    }

    /* Test: GTM601-IMEI */
    private bool gtm601_imei()
    {
        var tcase = ui.testcases.get( "gtm601_imei" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; (echo AT+CGSN; sleep 1) | ./femtocom /dev/ttyHS3' | fgrep ',' >/tmp/IMEI" );
        if ( res == 0 )
        {
            var file = File.new_for_path ("/tmp/IMEI");
            try
            {
                var dis = new DataInputStream (file.read ());
                string line = dis.read_line( null );
                tcase.update( ui, true, line[0:line.length-1] ); //-1: don't write the 2nd newline character (\n)
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

    /* Test: BMP085 */
    private bool bmp085()
    {
        var tcase = ui.testcases.get( "bmp085" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; cat /sys/bus/i2c/devices/i2c-2/2-0077/pressure' >/tmp/values" );
        if ( res == 0 )
        {
            var file = File.new_for_path ("/tmp/values");
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

    /* Test: ITG3200 */
    private bool itg3200()
    {
        var tcase = ui.testcases.get( "itg3200" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; cat /sys/bus/i2c/devices/i2c-2/2-0068/values' | fgrep ' ' >/tmp/values" );
        if ( res == 0 )
        {
            var file = File.new_for_path ("/tmp/values");
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

    /* Test: BMA180 */
    private bool bma180()
    {
        var tcase = ui.testcases.get( "bma180" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; cat /sys/bus/i2c/devices/i2c-2/2-0041/coord' | fgrep ',' >/tmp/values" );
        if ( res == 0 )
        {
            var file = File.new_for_path ("/tmp/values");
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

    /* Test: LIS302 */
    private bool lis302()
    {
        var tcase = ui.testcases.get( "lis302" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; echo y |i2cdetect -r 2 0x1d 0x1d' | fgrep ' 1d'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }

    /* Test: Si47xx */
    private bool si47xx()
    {
        var tcase = ui.testcases.get( "si47xx" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; echo y |i2cdetect -r 2 0x11 0x11' | fgrep ' UU'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }

    /* Test: TSC2007 */
    private bool tsc2007()
    {
        var tcase = ui.testcases.get( "tsc2007" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; cat /sys/bus/i2c/devices/i2c-2/2-0048/values' | fgrep ',' >/tmp/values" );
        if ( res == 0 )
        {
            var file = File.new_for_path ("/tmp/values");
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

    /* Test: HMC5883L */
    private bool hmc5883l()
    {
        var tcase = ui.testcases.get( "hmc5883l" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; echo y |i2cdetect -r 2 0x1d 0x1e' | fgrep ' 1e'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }

    /* Test: TCA6507 */
    private bool tca6507()
    {
        var tcase = ui.testcases.get( "tca6507" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; echo y |i2cdetect -r 2 0x45 0x45' | fgrep ' UU'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }

    /* Test: TPS61050 */
    private bool tps61050()
    {
        var tcase = ui.testcases.get( "tps61050" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; echo y |i2cdetect -r 2 0x33 0x33' | fgrep ' 33'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }

    /* Test: OV9655 */
    private bool ov9655()
    {
        var tcase = ui.testcases.get( "ov9655" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; echo y |i2cdetect -r 2 0x30 0x30' | fgrep ' UU'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }

    /* Test: M24LR64 */
    private bool m24lr64()
    {
        var tcase = ui.testcases.get( "m24lr64" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; echo y |i2cdetect -r 2 0x50 0x50' | fgrep ' 50'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }

    /* Test: RS232 */
    private bool rs232()
    {
        var tcase = ui.testcases.get( "rs232" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; (echo hello world; sleep 1) | /root/femtocom /dev/ttyS2' | fgrep 'hello world'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }

    /* Test: W2SG0004 */
    private bool w2sg0004()
    {
        var tcase = ui.testcases.get( "w2sg0004" );
        var res = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; echo 0 >/sys/devices/virtual/gpio/gpio145/value;echo 1 >/sys/devices/virtual/gpio/gpio145/value; stty 9600 </dev/ttyS1'" );
        int nok = 0;
        if ( res == 0 )
        {
            while ( true )
            {
                var res2 = Posix.system( "ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; read -t 2 </dev/ttyS1 LINE; echo $LINE' | fgrep '$GP' >/tmp/GPS" );
                if ( res2 == 0 )
                {
                    var file = File.new_for_path ("/tmp/GPS");
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
                else nok++;
                if ( nok > 3 ) // retrigger the gpio145
                {
                    var res3 = Posix.system( @"ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; echo 0 >/sys/devices/virtual/gpio/gpio145/value;echo 1 >/sys/devices/virtual/gpio/gpio145/value; stty 9600 </dev/ttyS1'" );
                }
                Posix.sleep( 1 );
                if(nok > 6)
                {
                    tcase.update( ui, false );
                    break;
                }
                Posix.sleep( 1 );
            }
        }
        return false;
    }

    /* Init WLAN/BT to test them */
    private bool _init_wlan_bt()
    {
        // Power on WLAN/BT chip
        var res = Posix.system( "ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; VDD=3150000; echo 255 >/sys/class/leds/tca6507:6/brightness; echo $VDD >/sys/devices/platform/reg-virt-consumer.4/max_microvolts; echo $VDD >/sys/devices/platform/reg-virt-consumer.4/min_microvolts; echo normal >/sys/devices/platform/reg-virt-consumer.4/mode; echo 0 >/sys/class/leds/tca6507:6/brightness; '" );
        Posix.sleep( 1 );
        // Start daemon (returns an error if already started)
        //var res2 = Posix.system( "ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; hciattach -n -s 115200 /dev/ttyS0 any 115200 flow&'" );
        return true;
    }

    /* Test: W2CBW003-WLAN */
    private bool w2cbw003_wlan()
    {
        var tcase = ui.testcases.get( "w2cbw003_wlan" );
        var res = Posix.system( "ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; ifconfig $(iwconfig|fgrep wlan|(read IF X Y ESSID; echo $IF)) up'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
            return true;
        }
        else
        {
            tcase.update( ui, false );
            return false;
        }
    }

    /* Test: W2CBW003-BT */
    private bool w2cbw003_bt()
    {
        var tcase = ui.testcases.get( "w2cbw003_bt" );
        var res = Posix.system( "ssh -o 'ConnectTimeout 2' root@192.168.0.202 sh -c 'cd; hciconfig hci0 up'" );
        if ( res == 0 )
        {
            tcase.update( ui, true, "" );
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
