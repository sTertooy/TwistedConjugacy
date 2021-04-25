###############################################################################
##
## ReidemeisterNumber( hom1, hom2 )
##
InstallMethod(
	ReidemeisterNumber,
	"for finite source and finite abelian range",
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	2,
	function ( hom1, hom2 )
		local G, H;
		G := Range( hom1 );
		H := Source( hom1 );
		if  (
			not IsFinite( H ) or
			not IsFinite( G ) or
			not IsAbelian( G )
		) then
			TryNextMethod();
		fi;
		return Size( G ) / Size( H ) * Size( CoincidenceGroup( hom1, hom2 ) );
	end
);

InstallMethod(
	ReidemeisterNumber,
	"for polycyclic or finite source and (polycyclic nilpotent-by-)finite range",
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	4,
	function ( hom1, hom2 )
		local G, H;
		G := Range( hom1 );
		H := Source( hom1 );
		if (
			( not IsPolycyclicGroup( H ) and
			  not IsFinite( H ) ) or 
			( not ( IsPolycyclicGroup( G ) and
				    IsNilpotentByFinite( G ) ) and
			  not IsFinite( G ) )
		) then
			TryNextMethod();
		fi;
		if HirschLength( H ) >= HirschLength( G ) then
			TryNextMethod();
		fi;
		return infinity;
	end
);

InstallMethod(
	ReidemeisterNumber,
	"for polycyclic source and abelian range",
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	1,
	function ( hom1, hom2 )
		local G;
		G := Range( hom1 );
		if (
			not IsPolycyclicGroup( Source( hom1 ) ) or
			not IsAbelian( G )
		) then
			TryNextMethod();
		fi;
		return IndexNC( G, Image(
			DifferenceGroupHomomorphisms@( hom1, hom2 )
		));
	end
);

InstallMethod(
	ReidemeisterNumber,
	"by counting Reidemeister classes",
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	0,
	function ( hom1, hom2 )
		local Rcl;
		Rcl := ReidemeisterClasses( hom1, hom2 );
		if Rcl <> fail then
			return Size( Rcl );
		else
			return infinity;
		fi;
	end
);


###############################################################################
##
## ReidemeisterNumber( endo )
##
InstallOtherMethod(
	ReidemeisterNumber,
	[ IsGroupHomomorphism and IsEndoGeneralMapping ],
	function ( endo )
		return ReidemeisterNumber( endo, IdentityMapping( Source( endo ) ) );
	end
);

RedispatchOnCondition(
	ReidemeisterNumber,
	true,
	[ IsGroupHomomorphism ],
	[ IsEndoGeneralMapping ],
	0
);
