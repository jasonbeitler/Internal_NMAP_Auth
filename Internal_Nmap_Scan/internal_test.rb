#!/usr/bin/env ruby
#
#	Ruby 1.9 Code
#

# Vars

begin
	email_hd        = '/email_header_default.txt'
	email           = '/email_header.txt'
	homeDir         = '/home/user'
	outFile         = "results"
	appDir          = "#{homeDir}/Internal_Nmap_Auth"
	confDir         = "#{appDir}/email"
	logDir          = "#{appDir}/logs/"
	logFile         = Time.now.to_s.gsub(/ /,'_')
	$logWriter      = File.new(logDir + logFile,'w')
	$finalOut		= <<-HEADER
From: email@ddress
To: jason.beitler@me.com
Subject: Home Scan

HEADER
rescue Exception => e
	puts "[!] Error: #{e.message}"
end

# Methods

# Writes messages to STDOUT and logfile
def log(message)
	begin
		puts "#{message}"
		$logWriter.puts(message + "\n")
	rescue Exception => e
		puts "[!] Error: #{e.message}"
	end
end

puts "moving to determines change"

# Did the nmap scan complete successfully?
def completed?(errCode, section)
        log("[!]Error: Could not scan #{section}") if not errCode or errCode.nil?
end

# Make final output for email
def makeEmail(aFile)
        begin
                inRead = File.open(aFile,'r')
                while line = inRead.gets
                        $finalOut << line
                end
        rescue Exception => e
                log("[!] Error: #{e.message}")
        ensure
                inRead.close if inRead
        end
end

# Begin


log("[+]Starting nmap scan.") # Status Update


# Scan DHCP Lease Range
log("[+]Scanning DHCP Lease Range...")
exitCode = system('/usr/bin/nmap -sS x.x.x.x-x -T4 -PN --open -R --dns-servers x.x.x.x -oX dhcp1.xml > dhcp_scan1.txt')
completed?(exitCode,'DHCP Range')


# Send Report

log("[+]Emailing report.")
$logWriter.close # Close log writer object

# Append log output to a variable to be put into the message body of the email
makeEmail(logDir + logFile)
makeEmail('dhcp_scan.txt')

# Send Email
require 'net/smtp'
require 'rubygems'
require 'tlsmail'
#smtp = Net::SMTP.new 'smtp.gamil.com', 587
begin

#smtp.enable_starttls

	Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
	Net::SMTP.start('smtp.gmail.com', 587, Socket.gethostname, 'email', 'password', :login) do |server|
		server.send_message($finalOut, 'To:email', [ 'To:email']) # Params: send_message(message_body, from, to[])
	end
rescue Exception => e
	puts "[!] Error: #{e.message}"
end
