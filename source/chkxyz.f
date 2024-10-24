c
c
c     ###################################################
c     ##  COPYRIGHT (C)  2000  by  Jay William Ponder  ##
c     ##              All Rights Reserved              ##
c     ###################################################
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine chkxyz  --  check for coincident coordinates  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "chkxyz" finds any pairs of atoms with identical Cartesian
c     coordinates, and prints a warning message
c
c
      subroutine chkxyz (clash)
      use atoms
      use iounit
      implicit none
      integer i,j
      real*8 xi,yi,zi
      real*8 eps,r2
      logical clash
      logical header
c
c
c     initialize distance tolerance and atom collision flag
c
      eps = 0.000001d0
      clash = .false.
      header = .true.
c
c     OpenMP directives for the major loop structure
c
!$OMP PARALLEL default(private)
!$OMP& shared(n,x,y,z,eps,clash,header)
!$OMP DO schedule(guided)
c
c     loop over atom pairs testing for identical coordinates
c
      do i = 1, n-1
         xi = x(i)
         yi = y(i)
         zi = z(i)
         do j = i+1, n
            r2 = (x(j)-xi)**2 + (y(j)-yi)**2 + (z(j)-zi)**2
            if (r2 .lt. eps) then
               clash = .true.
               if (header) then
                  header = .false.
                  write (iout,10)
   10             format ()
               end if
               write (iout,20)  i,j
   20          format (' CHKXYZ  --  Warning, Atoms',i6,' and',i6,
     &                    ' have Identical Coordinates')
            end if
         end do
      end do
c
c     OpenMP directives for the major loop structure
c
!$OMP END DO
!$OMP END PARALLEL
      return
      end
