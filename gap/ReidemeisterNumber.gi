###############################################################################
##
## ReidemeisterNumber( hom1, hom2 )
##
InstallMethod( ReidemeisterNumber, [IsGroupHomomorphism, IsGroupHomomorphism],
	function ( hom1, hom2 )
		local G, H, Rcl;
		G := Source( hom1 );
		H := Range( hom1 );
		if IsFinite( G ) and IsAbelian( G ) and IsFinite( H ) then
			TryNextMethod();
		fi;
		Rcl := ReidemeisterClasses( hom1, hom2 );
		if Rcl <> fail then
			return Size( Rcl );
		else
			return infinity;
		fi;
	end
);

InstallMethod( ReidemeisterNumber, [IsGroupHomomorphism, IsGroupHomomorphism],
	function ( hom1, hom2 )
		local G, H, Rcl;
		H := Source( hom1 );
		G := Range( hom1 );
		if not IsFinite( G ) or not IsFinite( H ) or
			not IsAbelian( G ) then
			TryNextMethod();
		fi;
		return Size( G ) / Size( H ) * Size( CoincidenceGroup( hom1, hom2 ) );
	end
);


InstallMethod( ReidemeisterNumber, "for torsion-free nilpotent groups",
	[IsGroupHomomorphism and IsEndoGeneralMapping,
	 IsGroupHomomorphism and IsEndoGeneralMapping],
	function ( hom1, hom2 )
		local G, ALCS, Rcl, i, Gi, Gip1, p, hom1N, hom2N, hom1Np, hom2Np, R;
		G := Source( hom1 );
		if not IsNilpotentGroup( G ) or not IsTorsionFree( G ) or IsAbelian( G ) then
			TryNextMethod();
		fi;
		ALCS := AdaptedLowerCentralSeriesOfGroup( G );
		R := 1;
		for i in [1..Length( ALCS )-1 ] do
			Gi := ALCS[i];
			Gip1 := ALCS[i+1];
			p := NaturalHomomorphismByNormalSubgroupNC( Gi, Gip1 );
			hom1N := RestrictedEndomorphism( hom1, Gi );
			hom2N := RestrictedEndomorphism( hom2, Gi );
			hom1Np := InducedEndomorphism( p, hom1N );
			hom2Np := InducedEndomorphism( p, hom2N );
			R := R * ReidemeisterNumber( hom1Np, hom2Np );
		od;
		Print("hallodaar\n");
		return R;
	end
);

InstallMethod( ReidemeisterNumber, "for abelian range",
	[IsGroupHomomorphism, IsGroupHomomorphism],
	function ( hom1, hom2 )
		local G, H, N;
		G := Range( hom1 );
		H := Source( hom1 );
		if not IsPcpGroup( H ) or not IsPcpGroup( G ) or
			not IsAbelian( H ) or not IsAbelian( G ) then
			TryNextMethod();
		fi;
		N := Image( DifferenceGroupHomomorphisms@( hom1, hom2 ) );
		return IndexNC( G, N );
	end
);

RedispatchOnCondition( ReidemeisterNumber, true, 
	[IsGroupHomomorphism, IsGroupHomomorphism],
	[IsEndoGeneralMapping, IsEndoGeneralMapping], 0 );


###############################################################################
##
## ReidemeisterNumber( endo )
##
InstallOtherMethod( ReidemeisterNumber, 
	[IsGroupHomomorphism and IsEndoGeneralMapping],
	function ( endo )
		return ReidemeisterNumber( endo, IdentityMapping( Source( endo ) ) );
	end
);

RedispatchOnCondition( ReidemeisterNumber, true, 
	[IsGroupHomomorphism],
	[IsEndoGeneralMapping], 0 );
