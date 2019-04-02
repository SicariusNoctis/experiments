! To compile and run: make

program q1
  use integrator
  use utils
  implicit none

  integer, parameter :: nn = 3
  integer, parameter :: step_rate = 2**8
  real, parameter :: dt = 1.0 / step_rate
  real, parameter :: pi = 3.1415926535897932384626433832795028841971693993751058

  call main()
  call find_eigenvalues()

contains

  subroutine main()
    integer, parameter :: steps = 2.0 * step_rate, bi_steps = 2 * steps - 1
    real :: ys(nn, bi_steps)
    real :: y0(nn) = [0.0, 1.0, 1.0]
    real :: results(4, bi_steps)
    real, dimension(bi_steps) :: psis_even, psis_odd

    E = 4.20
    print *
    print "(a)", "Q1. Plot wavefunction"
    print "(a, f9.7)", "    dt:      ", dt
    print "(a, f9.7)", "    E:       ", E
    print "(a, f9.7)", "    psi(0):  ", y0(2)
    print "(a, f9.7)", "    dpsi(0): ", y0(3)
    call integrate_ode_bidirectional(steps, dt, ys, y0)
    print "(a, f9.7)", "    N:       ", integrate_sum(dt, ys)
    print *

    call separate_even_odd(ys(2, :), psis_even, psis_odd)
    results(1, :) = ys(1, :)
    results(2, :) = psis_even
    results(3, :) = psis_odd
    results(4, :) = ys(3, :)

    call write_csv("results_q1.csv", results, &
      "$x$, &
      &$\psi_+(x)$, &
      &$\psi_-(x)$, &
      &$\frac{d}{dx}\psi(x)$")

    call execute_command_line("python plot.py --time-series --nrows 2 &
      &--title 'Even/odd wavefunctions at E = 4.2' &
      &results_q1.csv &
      &plot_q1.png")
  end subroutine

  subroutine find_eigenvalues()
    integer, parameter :: steps = 8.0 * step_rate, bi_steps = 2 * steps - 1
    integer, parameter :: iters = 101
    real :: ys(nn, bi_steps), results(3, iters), lambdas(10)
    real, dimension(bi_steps) :: psis_even, psis_odd
    integer :: i

    do i = 1, iters
      E = 0.5 + 10.0 * (i - 1) / (iters - 1)
      call integrate_ode_bidirectional(steps, dt, ys, y0=[0.0, 1.0, 1.0])
      call separate_even_odd(ys(2, :), psis_even, psis_odd)
      results(1, i) = E
      results(2, i) = psis_even(bi_steps)
      results(3, i) = psis_odd(bi_steps)
    end do

    print "(a)", "Q2. Energy eigenvalues"

    call write_csv("results_q2.csv", results, &
      "$E$, &
      &$\log (1 + |\psi_+(\infty)|)$, &
      &$\log (1 + |\psi_-(\infty)|)$")

    call execute_command_line("python plot.py --q2 results_q2.csv plot_q2.png")

    ! TODO plot the various psi, psi^2 graphs for eigenvalues

    ! lambdas = [(0.5 + i, i = 0, 9)]
    lambdas(1:10:2) = k_minimums(5, results(1, :), results(2, :), .true.)
    lambdas(2:10:2) = k_minimums(5, results(1, :), results(3, :), .false.)
    call partial_sort(lambdas)
    ! print *, min(results(2:3, :), 1)
    ! lambdas = k_minimums(10, results(1, :), min(results(2:3, :), 1))
    print "(f19.12)", lambdas
    call plot_wavefunctions("q2_wavefunctions", lambdas)
  end subroutine

  subroutine plot_wavefunctions(suffix, lambdas)
    integer, parameter :: steps = 4.0 * step_rate, bi_steps = 2 * steps - 1
    real :: ys(nn, bi_steps)
    real :: y0(nn) = [0.0, 0.0, 1.0]
    character(len=*) :: suffix
    real :: lambdas(:), results(11, bi_steps)
    integer :: i

    do i = 1, size(lambdas, 1)
      E = lambdas(i)
      if (mod(i - 1, 2) == 0) y0 = [0.0, 1.0, 0.0]
      if (mod(i - 1, 2) == 1) y0 = [0.0, 0.0, 1.0]
      call integrate_ode_bidirectional(steps, dt, ys, y0)  ! TODO odd, even?
      results(i + 1, :) = ys(2, :)
    end do
    results(1, :) = ys(1, :)

    ! TODO specific energy labels? (construct string)
    call write_csv("results_" // suffix // ".csv", results, &
      "$x$, &
      &$\psi(x; E_1)$, &
      &$\psi(x; E_2)$, &
      &$\psi(x; E_3)$, &
      &$\psi(x; E_4)$, &
      &$\psi(x; E_5)$, &
      &$\psi(x; E_6)$, &
      &$\psi(x; E_7)$, &
      &$\psi(x; E_8)$, &
      &$\psi(x; E_9)$, &
      &$\psi(x; E_{10})$")

    call execute_command_line("python plot.py --time-series &
      &--title 'Wavefunctions for various energy eigenvalues' &
      &results_" // suffix // ".csv &
      &plot_"    // suffix // ".png")
  end subroutine

end program q1

! Q1 TODO
! Accuracy 1e-12 (what's error) similar to delta = matmul(H,psi) - lmbda*psi?
! Integration stop condition

! Q2 TODO
! Violation of BC
! Find E values via bisection on "bracketed roots" (? what's this) for even/odd modes
! Plot psi and psi^2

! TODO uhh... the dx_dt = -1.0 doesn't seem to give correct odd functions

