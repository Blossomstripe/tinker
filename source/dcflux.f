c
c
c     ##########################################################
c     ##  COPYRIGHT (C) 2020 by Chengwen Liu & Jay W. Ponder  ##
c     ##                 All Rights Reserved                  ##
c     ##########################################################
c
c     ##############################################################
c     ##                                                          ##
c     ##  subroutine dcflux  --  charge flux gradient components  ##
c     ##                                                          ##
c     ##############################################################
c
c
c     "dcflux" takes as input the electrostatic potential at each
c     atomic site and calculates force corrections due to charge
c     flux coupled with bond stretching and angle bending
c
c     literature reference:
c
c     C. Liu, J.-P. Piquemal and P. Ren, "Implementation of Geometry-
c     Dependent Charge Flux into the Polarizable AMOEBA+ Potential",
c     Journal of Physical Chemistry Letters, 11, 419-426 (2020)
c
c
      subroutine dcflux (pot,dcfx,dcfy,dcfz)
      use sizes
      use angbnd
      use atoms
      use bndstr
      use bound
      use cflux
      use math
      use mutant
      implicit none
      integer i,ia,ib,ic
      real*8 xa,ya,za
      real*8 xb,yb,zb
      real*8 xc,yc,zc
      real*8 xba,yba,zba
      real*8 xbc,ybc,zbc
      real*8 rba,rba2,rba3
      real*8 rbc,rbc2,rbc3
      real*8 dpot,dpota,dpotc
      real*8 ddqdx,ddqdy,ddqdz
      real*8 fx,fy,fz
      real*8 fxa1,fya1,fza1
      real*8 fxb1,fyb1,fzb1
      real*8 fxc1,fyc1,fzc1
      real*8 fxa2,fya2,fza2
      real*8 fxb2,fyb2,fzb2
      real*8 fxc2,fyc2,fzc2
      real*8 pjb,pjb1,pjb2
      real*8 pja1,pja2
      real*8 dot,term,fterm
      real*8 termxa,termxc
      real*8 termya,termyc
      real*8 termza,termzc
      real*8 pot(*)
      real*8 dcfx(*)
      real*8 dcfy(*)
      real*8 dcfz(*)
      logical muta,mutb,mutc
c
c
c     zero out the charge flux correction forces
c
      do i = 1, n
         dcfx(i) = 0.0d0
         dcfy(i) = 0.0d0
         dcfz(i) = 0.0d0
      end do
c
c     calculate the charge flux forces due to bond stretching
c
      do i = 1, nbond
         ia = ibnd(1,i)
         ib = ibnd(2,i)
         pjb = bflx(i)
         muta = mut(ia)
         mutb = mut(ib)
         if (muta .or. mutb) then
            pjb = pjb * elambda
         end if
         xa = x(ia)
         ya = y(ia)
         za = z(ia)
         xb = x(ib)
         yb = y(ib)
         zb = z(ib)
         xba = xa - xb
         yba = ya - yb
         zba = za - zb
         if (use_polymer)  call image (xba,yba,zba)
         rba2 = xba*xba + yba*yba + zba*zba
         pjb = pjb / sqrt(rba2)
         dpot = pot(ib) - pot(ia)
         ddqdx = (xa-xb) * pjb
         ddqdy = (ya-yb) * pjb
         ddqdz = (za-zb) * pjb
         fx = dpot * ddqdx
         fy = dpot * ddqdy
         fz = dpot * ddqdz
         dcfx(ia) = dcfx(ia) + fx
         dcfy(ia) = dcfy(ia) + fy
         dcfz(ia) = dcfz(ia) + fz
         dcfx(ib) = dcfx(ib) - fx
         dcfy(ib) = dcfy(ib) - fy
         dcfz(ib) = dcfz(ib) - fz
      end do
c
c     calculate the charge flux forces due to angle bending
c
      do i = 1, nangle
         ia = iang(1,i)
         ib = iang(2,i)
         ic = iang(3,i)
         pja1 = aflx(1,i)
         pja2 = aflx(2,i)
         pjb1 = abflx(1,i)
         pjb2 = abflx(2,i)
         muta = mut(ia)
         mutb = mut(ib)
         mutc = mut(ic)
         if (muta .or. mutb .or. mutc) then
            pja1 = pja1 * elambda
            pja2 = pja2 * elambda
            pjb1 = pjb1 * elambda
            pjb2 = pjb2 * elambda
         end if
         xa = x(ia)
         ya = y(ia)
         za = z(ia)
         xb = x(ib)
         yb = y(ib)
         zb = z(ib)
         xc = x(ic)
         yc = y(ic)
         zc = z(ic)
         xba = xa - xb
         yba = ya - yb
         zba = za - zb
         xbc = xc - xb
         ybc = yc - yb
         zbc = zc - zb
         if (use_polymer) then
            call image (xba,yba,zba)
            call image (xbc,ybc,zbc)
         end if
         rba2 = xba*xba + yba*yba + zba*zba
         rba  = sqrt(rba2)
         rba3 = rba2 * rba
         rbc2 = xbc*xbc + ybc*ybc + zbc*zbc
         rbc  = sqrt(rbc2)
         rbc3 = rbc2 * rbc
c
c     terms due to coupling with bond stretches in the angle
c
         dpota = pot(ia) - pot(ib)
         dpotc = pot(ic) - pot(ib)
         pjb1 = dpota * pjb1
         pjb2 = dpotc * pjb2
         fxa1 = pjb2 * xba/rba
         fya1 = pjb2 * yba/rba
         fza1 = pjb2 * zba/rba
         fxc1 = pjb1 * xbc/rbc
         fyc1 = pjb1 * ybc/rbc
         fzc1 = pjb1 * zbc/rbc
         fxb1 = -fxa1 - fxc1
         fyb1 = -fya1 - fyc1
         fzb1 = -fza1 - fzc1
c
c     terms due to coupling with the bond angle bending
c
         dot = xba*xbc + yba*ybc + zba*zbc
         term = -radian*rba*rbc / sqrt(rba2*rbc2-dot*dot)
         fterm = term * (dpota*pja1+dpotc*pja2)
         termxa = xbc/(rba*rbc) - xba*dot/(rba3*rbc)
         termya = ybc/(rba*rbc) - yba*dot/(rba3*rbc)
         termza = zbc/(rba*rbc) - zba*dot/(rba3*rbc)
         termxc = xba/(rba*rbc) - xbc*dot/(rba*rbc3)
         termyc = yba/(rba*rbc) - ybc*dot/(rba*rbc3)
         termzc = zba/(rba*rbc) - zbc*dot/(rba*rbc3)
         fxa2 = fterm * termxa
         fya2 = fterm * termya
         fza2 = fterm * termza
         fxc2 = fterm * termxc
         fyc2 = fterm * termyc
         fzc2 = fterm * termzc
         fxb2 = -fxa2 - fxc2
         fyb2 = -fya2 - fyc2
         fzb2 = -fza2 - fzc2
         dcfx(ia) = dcfx(ia) + fxa1 + fxa2
         dcfy(ia) = dcfy(ia) + fya1 + fya2
         dcfz(ia) = dcfz(ia) + fza1 + fza2
         dcfx(ib) = dcfx(ib) + fxb1 + fxb2
         dcfy(ib) = dcfy(ib) + fyb1 + fyb2
         dcfz(ib) = dcfz(ib) + fzb1 + fzb2
         dcfx(ic) = dcfx(ic) + fxc1 + fxc2
         dcfy(ic) = dcfy(ic) + fyc1 + fyc2
         dcfz(ic) = dcfz(ic) + fzc1 + fzc2
      end do
      return
      end