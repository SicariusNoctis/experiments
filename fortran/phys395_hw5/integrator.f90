module integrator
  implicit none

  interface
    function pR2R(x)
      !! Real -> Real
      real, intent(in) :: x
      real :: pR2R
    end function pR2R
  end interface

  real, parameter :: hbar2 = 1.0, m = 1.0, omega = 1.0
  real :: E = 1.5
  procedure(pR2R), pointer :: V => V_harmonic

contains

  function V_harmonic(x)
    real, intent(in) :: x
    real :: V_harmonic

    V_harmonic = 0.5 * m * omega**2 * x**2
  end function

  function V_anharmonic(x)
    real, intent(in) :: x
    real :: V_anharmonic

    V_anharmonic = 0.25 * x**4
  end function

  function evalf(y) result(dydt)
    real, intent(in) :: y(3)
    real :: dydt(3)

    associate(x => y(1), psi => y(2), dpsi => y(3))
      dydt(1) = 1.0
      dydt(2) = dpsi
      dydt(3) = (2 * m / hbar2) * (V(x) - E) * psi
    end associate
  end function

  ! 10th order implicit Gauss-Legendre integrator
  subroutine gl10(y, dt)
    integer, parameter :: s = 5, n = 3
    real y(n), g(n, s), dt
    integer i, k

    ! Butcher tableau for 10th order Gauss-Legendre method
    real, parameter :: a(s, s) = reshape([ &
      0.5923172126404727187856601017997934066Q-1,  &
      -1.9570364359076037492643214050884060018Q-2, &
      1.1254400818642955552716244215090748773Q-2,  &
      -0.5593793660812184876817721964475928216Q-2, &
      1.5881129678659985393652424705934162371Q-3,  &
      1.2815100567004528349616684832951382219Q-1,  &
      1.1965716762484161701032287870890954823Q-1,  &
      -2.4592114619642200389318251686004016630Q-2, &
      1.0318280670683357408953945056355839486Q-2,  &
      -2.7689943987696030442826307588795957613Q-3, &
      1.1377628800422460252874127381536557686Q-1,  &
      2.6000465168064151859240589518757397939Q-1,  &
      1.4222222222222222222222222222222222222Q-1,  &
      -2.0690316430958284571760137769754882933Q-2, &
      4.6871545238699412283907465445931044619Q-3,  &
      1.2123243692686414680141465111883827708Q-1,  &
      2.2899605457899987661169181236146325697Q-1,  &
      3.0903655906408664483376269613044846112Q-1,  &
      1.1965716762484161701032287870890954823Q-1,  &
      -0.9687563141950739739034827969555140871Q-2, &
      1.1687532956022854521776677788936526508Q-1,  &
      2.4490812891049541889746347938229502468Q-1,  &
      2.7319004362580148889172820022935369566Q-1,  &
      2.5888469960875927151328897146870315648Q-1,  &
      0.5923172126404727187856601017997934066Q-1], [s, s])

    real, parameter :: b(s) = [ &
      1.1846344252809454375713202035995868132Q-1, &
      2.3931433524968323402064575741781909646Q-1, &
      2.8444444444444444444444444444444444444Q-1, &
      2.3931433524968323402064575741781909646Q-1, &
      1.1846344252809454375713202035995868132Q-1]

    g = 0.0
    do k = 1, 16
      g = matmul(g, a)
      do i = 1, s
        g(:, i) = evalf(y + g(:, i) * dt)
      end do
    end do

    y = y + matmul(g, b) * dt
  end subroutine gl10

end module
