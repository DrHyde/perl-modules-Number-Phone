use ExtUtils::MakeMaker;
WriteMakefile(
		NAME         => 'Number::Phone',
		VERSION      => 1.57,
		PREREQ_PM    => {
			'Scalar::Util'	=> 0,
			# commented out cos 1.0 is incompatible
                        # 'DBM::Deep'	=> 0.97, # need to pass DATA filehandle
		}
	     );
