
use Net::FTP::Conn;
use Net::FTP::Config;
use Net::FTP::Buffer;
use Net::FTP::Format;

unit class Net::FTP::Transfer is Net::FTP::Conn;

has $.ascii;

#	%args 
#	host port passive ascii family encoding
method new (*%args is copy) {
	%args<listen> = %args<passive>;
	nextsame(|%args);
}

method readlist() {
	my @infos;

	while (my $buf = self.recv(:bin)) {
		for split($buf, Buf.new(0x0d, 0x0a)) {
			push @infos, format($_.unpack("A*"));
		}
	}

	@infos;
}

method readline() {
    return self.getline();
}

method readall(Bool :$bin? = False) {
    my @infos;
    my $left;

    while (my $buf = self.recv(:bin)) {
        if $bin {
            @infos.push: $buf;
        } else {
            $left = merge($left, $buf);
            for split($left, Buf.new(0x0d, 0x0a)) {
                push @infos, $_.unpack("A*");
            }
        }
    }

    return $bin ?? @infos !! @infos.join();
}

method read(Bool :$bin? = False) {
    return self.recv(:bin($bin.defined));
}

# vim: ft=perl6